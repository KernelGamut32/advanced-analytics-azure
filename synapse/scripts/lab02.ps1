Clear-Host
write-host "Starting script at $(Get-Date)"

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Az.Synapse -Force

$Region = Read-Host "Enter the region where your Synapse workspace is hosted (e.g., East US 2)"
$resourceGroupName = Read-Host "Enter the resource group name where your Synapse workspace is located"
$synapseWorkspace = Read-Host "Enter Synapse workspace name"
$dataLakeAccountName = Read-Host "Enter Data Lake account name"

# Upload files
write-host "Loading data..."
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $dataLakeAccountName
$storageContext = $storageAccount.Context
Get-ChildItem "./data/*.csv" -File | Foreach-Object {
    write-host ""
    $file = $_.Name
    Write-Host $file
    $blobPath = "sales/csv/$file"
    Set-AzStorageBlobContent -File $_.FullName -Container "files" -Blob $blobPath -Context $storageContext
}

Get-ChildItem "./data/*.parquet" -File | Foreach-Object {
    write-host ""
    Write-Host $_.Name
    $folder = $_.Name.Replace(".snappy.parquet", "")
    $file = $_.Name.Replace($folder, "orders")
    $blobPath = "sales/parquet/year=$folder/$file"
    Set-AzStorageBlobContent -File $_.FullName -Container "files" -Blob $blobPath -Context $storageContext
}

Get-ChildItem "./data/*.json" -File | Foreach-Object {
    write-host ""
    $file = $_.Name
    Write-Host $file
    $blobPath = "sales/json/$file"
    Set-AzStorageBlobContent -File $_.FullName -Container "files" -Blob $blobPath -Context $storageContext
}

write-host "Script completed at $(Get-Date)"