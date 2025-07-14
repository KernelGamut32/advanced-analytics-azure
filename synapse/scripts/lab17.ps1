Clear-Host
write-host "Starting script at $(Get-Date)"

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Az.Synapse -Force

$Region = Read-Host "Enter the region where your Synapse workspace is hosted (e.g., East US 2)"
$resourceGroupName = Read-Host "Enter the resource group name where your Synapse workspace is located"
$synapseWorkspace = Read-Host "Enter Synapse workspace name"
$dataLakeAccountName = Read-Host "Enter Data Lake account name"

# Upload files
write-host "Uploading files..."
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $dataLakeAccountName
$storageContext = $storageAccount.Context
$container = Get-AzStorageContainer -Context $storageContext -Name 'files' -ErrorAction SilentlyContinue
if (-not $container) {
    New-AzStorageContainer -Name "files" -Context $storageContext -Permission Off
}
Get-ChildItem "./data/*.csv" -File | Foreach-Object {
    write-host ""
    $file = $_.Name
    Write-Host $file
    $blobPath = "data/$file"
    Set-AzStorageBlobContent -File $_.FullName -Container "files" -Blob $blobPath -Context $storageContext
}

# Import notebooks
write-host "Importing notebooks..."
Get-ChildItem "./notebooks/*.ipynb" -File | Foreach-Object {
    write-host ""
    $file = $_.FullName
    $name = $_.Name
    Write-Host "Importing $name ..."
    az synapse notebook import --workspace-name $synapseWorkspace --name $name.Replace(".ipynb", "") --file "@$file" --only-show-errors >/dev/null
}

write-host "Script completed at $(Get-Date)"