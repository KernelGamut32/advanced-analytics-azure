Clear-Host
write-host "Starting script at $(Get-Date)"

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Az.Synapse -Force

# Install Azure ML CLI
az extension remove -n azure-cli-ml
az extension remove -n ml
az extension add -n ml -y

# Prompt user for a password for the SQL Database
$sqlUser = "sqladminuser"
write-host ""
$sqlPassword = ""

$SqlPassword = Read-Host "Enter the password to use for the $sqlUser login"

# Generate unique random suffix
[string]$suffix =  -join ((48..57) + (97..122) | Get-Random -Count 7 | % {[char]$_})
Write-Host "Your randomly-generated suffix for Azure resources is $suffix"

$Region = Read-Host "Enter the region where your Synapse workspace is hosted (e.g., East US 2)"
$resourceGroupName = Read-Host "Enter the resource group name where your Synapse workspace is located"
$synapseWorkspace = Read-Host "Enter Synapse workspace name"
$dataLakeAccountName = Read-Host "Enter Data Lake account name"
$sqlDatabaseName = Read-Host "Enter dedicated SQL pool name"

# Upload files
write-host "Uploading files..."
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $dataLakeAccountName
$storageContext = $storageAccount.Context
$container = Get-AzStorageContainer -Context $storageContext -Name 'files' -ErrorAction SilentlyContinue
if (-not $container) {
    New-AzStorageContainer -Name "files" -Context $storageContext -Permission Off
}
Get-ChildItem "./files/*.csv" -File | Foreach-Object {
    write-host ""
    $file = $_.Name
    Write-Host $file
    $blobPath = "data/$file"
    Set-AzStorageBlobContent -File $_.FullName -Container "files" -Blob $blobPath -Context $storageContext
}

# Create database
write-host "Creating the $sqlDatabaseName database..."
$setupSQL = Get-Content -Path "setup.sql" -Raw
$setupSQL = $setupSQL.Replace("datalakexxxxxxx", $dataLakeAccountName)
Set-Content -Path "setup$suffix.sql" -Value $setupSQL
sqlcmd -S "$synapseWorkspace.sql.azuresynapse.net" -U $sqlUser -P $sqlPassword -d $sqlDatabaseName -I -i setup$suffix.sql

write-host "Script completed at $(Get-Date)"