#requires -Version 5
#requires -Modules @{ ModuleName='Microsoft.PowerShell.Utility'; ModuleVersion='3.1.0.0' }
#requires -Modules @{ ModuleName='Microsoft.PowerShell.Management'; ModuleVersion='3.1.0.0' }
#requires -Modules @{ ModuleName='Azure.Storage'; ModuleVersion='2.6.0' }


function CreateNewAzureStorageContainer
{
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext] $Context,

        [Parameter(Mandatory = $true)]
        [string] $ContainerName,

        [Parameter(Mandatory = $false)]
        [int] $SleepSeconnds = 5
    )

    while ($true)
    {
        try
        {
            [void] (New-AzureStorageContainer -Context $Context -Name $ContainerName -Permission Blob -ErrorAction Stop)
            break
        }
        catch
        {
            # The remote server returned an error: (409) Conflict. HTTP Status Code: 409 - HTTP Error Message: The specified container is being deleted. Try operation later.
            if (($_.FullyQualifiedErrorId -eq 'StorageException,Microsoft.WindowsAzure.Commands.Storage.Blob.Cmdlet.NewAzureStorageContainerCommand') -and
                ($_.Exception.InnerException -ne $null) -and ($_.Exception.InnerException.RequestInformation.HttpStatusCode -eq 409))
            {
                Write-Verbose -Message $_.Exception.Message

                # Waiting for Azure.
                $SleepSeconnds = 5
                Write-Verbose -Message ('Waiting {0} seconds.' -f $SleepSeconnds)
                Start-Sleep -Seconds $SleepSeconnds
            }
            else
            {
                throw $_
            }
        }
    }
}


function Set-AzureArmTemplateFile
{
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true)]
        [string] $LocalBasePath,

        [Parameter(Mandatory = $true)]
        [string] $StorageAccountName,

        [Parameter(Mandatory = $true)]
        [string] $StorageAccountKey,

        [Parameter(Mandatory = $false)]
        [string] $ContainerName = 'armtemplate',

        [Parameter(Mandatory = $false)]
        [switch] $Force = $false
    )

    # Standardize the path.
    if (-not $LocalBasePath.EndsWith('\'))
    {
        $LocalBasePath += '\'
    }

    # Get a storage context.
    $context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    Write-Verbose -Message ('Got the storage context of ''{0}'' account.' -f $context.StorageAccountName)

    # Create a container if it not exist.
    $container = Get-AzureStorageContainer -Context $context -Name $ContainerName -ErrorAction SilentlyContinue
    if ($container -eq $null)
    {
        Write-Verbose -Message ('Create a new container, because the ''{0}'' container is does not exist in ''{1}'' account.' -f $ContainerName,$context.StorageAccountName)
        CreateNewAzureStorageContainer -Context $context -ContainerName $ContainerName
    }
    else
    {
        Write-Verbose -Message ('The ''{0}'' container is exist in ''{1}'' account.' -f $ContainerName,$context.StorageAccountName)
    }

    # Upload the files.
    Get-ChildItem -LiteralPath $LocalBasePath -File -Recurse |
        ForEach-Object -Process {
    
            $localFilePath = $_.FullName

            # Create blob name from local file path.
            $blobName = $localFilePath.Replace($localBasePath,'').Replace('\', '/')

            # Upload a file.
            Write-Verbose -Message ('Uploading "{0}" to {1}{2}/{3} ...' -f $localFilePath,$context.BlobEndPoint,$ContainerName,$blobName)
            $result = Set-AzureStorageBlobContent -Context $context -File $localFilePath -Container $ContainerName -Blob $blobName -BlobType Block -Force:$Force

            [PSCustomObject] @{
                Uri = $result.ICloudBlob.StorageUri.PrimaryUri
            }
        }
}

function Get-AzureArmTemplateDeployUri
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $TemplateUri,

        [Parameter(Mandatory = $false)]
        [switch] $ShowDeployBlade = $false

    )

    $createUri = 'https://portal.azure.com/#create/Microsoft.Template/uri/'
    $encodedTemplateUri = $TemplateUri.Replace(':', '%3A').Replace('/', '%2F')

    $uri = $createUri + $encodedTemplateUri

    if ($ShowDeployBlade)
    {
        # Open the template deploy blade.
        Start-Process -FilePath $uri
    }

    [PSCustomObject] @{
        Uri = $uri
    }
}
