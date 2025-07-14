Clear-Host
write-host "Starting script at $(Get-Date)"

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Az.Synapse -Force

# Prompt user for a password for the SQL Database
$sqlUser = "sqladminuser"
write-host ""
$sqlPassword = ""
$complexPassword = 0

while ($complexPassword -ne 1)
{
    $SqlPassword = Read-Host "Enter the password to use for the $sqlUser login.
    `The password must meet complexity requirements:
    ` - Minimum 8 characters. 
    ` - At least one upper case English letter [A-Z]
    ` - At least one lower case English letter [a-z]
    ` - At least one digit [0-9]
    ` - At least one special character (!,@,#,%,^,&,$)
    ` "

    if(($SqlPassword -cmatch '[a-z]') -and ($SqlPassword -cmatch '[A-Z]') -and ($SqlPassword -match '\d') -and ($SqlPassword.length -ge 8) -and ($SqlPassword -match '!|@|#|%|^|&|$'))
    {
        $complexPassword = 1
	    Write-Output "Password $SqlPassword accepted. Make sure you remember this!"
    }
    else
    {
        Write-Output "$SqlPassword does not meet the complexity requirements."
    }
}

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
Get-ChildItem "./data/*.csv" -File | Foreach-Object {
    write-host ""
    $file = $_.Name
    Write-Host $file
    $blobPath = "data/$file"
    Set-AzStorageBlobContent -File $_.FullName -Container "files" -Blob $blobPath -Context $storageContext
}

#Create output directory with file
write-host "Uploading files..."
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $dataLakeAccountName
$storageContext = $storageAccount.Context
Get-ChildItem "./customer-output/*.csv" -File | Foreach-Object {
    write-host ""
    $file = $_.Name
    Write-Host $file
    $blobPath = "customer-output/$file"
    Set-AzStorageBlobContent -File $_.FullName -Container "files" -Blob $blobPath -Context $storageContext
}

write-host "Script completed at $(Get-Date)"