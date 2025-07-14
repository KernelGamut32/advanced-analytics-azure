Clear-Host
write-host "Starting script at $(Get-Date)"

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Az.Synapse -Force

# Prompt user for a password for the SQL Database
$sqlUser = "sqladminuser"
write-host ""
$sqlPassword = ""

$SqlPassword = Read-Host "Enter the password to use for the $sqlUser login"

$Region = Read-Host "Enter the region where your Synapse workspace is hosted (e.g., East US 2)"
$resourceGroupName = Read-Host "Enter the resource group name where your Synapse workspace is located"
$synapseWorkspace = Read-Host "Enter Synapse workspace name"
$dataLakeAccountName = Read-Host "Enter Data Lake account name"
$sqlDatabaseName = Read-Host "Enter dedicated SQL pool name"

# Create database
write-host "Creating the $sqlDatabaseName database..."
sqlcmd -S "$synapseWorkspace.sql.azuresynapse.net" -U $sqlUser -P $sqlPassword -d $sqlDatabaseName -I -i setup.sql

# Load data
write-host "Loading data..."
Get-ChildItem "./data/*.txt" -File | Foreach-Object {
    write-host ""
    $file = $_.FullName
    Write-Host "$file"
    $table = $_.Name.Replace(".txt","")
    bcp dbo.$table in $file -S "$synapseWorkspace.sql.azuresynapse.net" -U $sqlUser -P $sqlPassword -d $sqlDatabaseName -f $file.Replace("txt", "fmt") -q -k -E -b 5000
}

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

write-host "Script completed at $(Get-Date)"