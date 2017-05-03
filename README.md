# AzureArmTemplateHelper PowerShell Module
This is PowerShell module that help for Azure ARM template making. This module contains two cmdlets.

- Set-AzureArmTemplateFile cmdlet
- Get-AzureArmTemplateDeployUri cmdlet

## Install
This module available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/AzureArmTemplateHelper/) page. You can install use the Install-Module cmdlet.

```PowerShell
PS > Install-Module -Name AzureArmTemplateHelper 
```

## Set-AzureArmTemplateFile cmdlet
This cmdlet helping to ARM template making by upload the ARM template files on local filesystem to blob storage of Azure storage. When you making linked ARM template, this cmdlet is especially helpful.

### Parameters

Parameter Name     | Description
-------------------|-------------------
LocalBasePath      | The path of the folder on local filesystem that contains the ARM templates.
StorageAccountName | The storage account name to upload the ARM templates.
ResourceGroupName  | The resource group name that it contains the storage account of StorageAccountName parameter.
StorageAccountKey  | The storage account key for storage account of StorageAccountName parameter.
ContainerName      | The container name to upload the ARM templates. This parameter is optional. Default container name is 'armtemplate'.
Force              | This switch parameter is optional. If you use this switch, overwrite the existing ARM templates in the container.

### Examples

#### Example 1
This example is upload the ARM template files from under 'C:\TemplateWork' folder with recursive. You need execute Login-AzureRmAccount cmdlet before execute this cmdlet because this example use ResourceGroupName parameter.

```PowerShell
PS > Set-AzureArmTemplateFile -LocalBasePath 'C:\TemplateWork' -StorageAccountName 'abcd1234' -ResourceGroupName 'ArmTemplateDev-RG' -Force
```

#### Example 2
This example is upload the ARM template files from under 'C:\TemplateWork' folder with recursive.

```PowerShell
PS > Set-AzureArmTemplateFile -LocalBasePath 'C:\TemplateWork' -StorageAccountName 'abcd1234' -StorageAccountKey 'dWLe7OT3P0HevzLeKzRlk4j4eRws7jHStp0C4XJtQJhuH4p5EOP+vLcK1w8sZ3QscGLy50DnOzQoiUbpzXD9Jg==' -Force
```


## Get-AzureArmTemplateDeployUri cmdlet
This cmdlet building the URL that is access to custom deployment blade on Azure Portal. The URL allows deployment of your ARM template via Azure Portal.

Parameter Name  | Description
----------------|-------------------
TemplateUri     | The URI of your ARM template.
ShowDeployBlade | This switch parameter is optional. If you use this switch, this cmdlet open the URL by your browser.

### Examples

#### Example 1
This example is build the URL of custom deployment blade from your ARM template URL.

```PowerShell
PS > Get-AzureArmTemplateDeployUri -TemplateUri 'https://abcd1234.blob.core.windows.net/armtemplate/main.json'

Uri
---
https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fabcd1234.blob.core.windows.net%2Farmtemplate%2Fmain.json
```

#### Example 2
This example is build the URL of custom deployment blade from your ARM template URL and open that URL by your browser.

```PowerShell
PS > Get-AzureArmTemplateDeployUri -TemplateUri 'https://abcd1234.blob.core.windows.net/armtemplate/main.json' -ShowDeployBlade
```


## Release Notes

### [1.0.1](https://github.com/tksh164/AzureArmTemplateHelper/releases/tag/1.0.1)
- Added help for cmdlets.

### [1.0.0](https://github.com/tksh164/AzureArmTemplateHelper/releases/tag/1.0.0)
- Initial release.
