$downloadsPath = "$env:USERPROFILE\Downloads"
$repoPath = $PSScriptRoot
$tempPath = "$repoPath\_temp"

# Find latest ZIP
$zip = Get-ChildItem $downloadsPath -Filter *.zip |
       Sort-Object LastWriteTime -Descending |
       Select-Object -First 1

if (-not $zip) {
    Write-Host "No ZIP file found"
    exit
}

Write-Host "Latest ZIP found:" $zip.Name

# Clean temp folder
if (Test-Path $tempPath) {
    Remove-Item $tempPath -Recurse -Force
}
New-Item -ItemType Directory $tempPath | Out-Null

# Unzip
Expand-Archive $zip.FullName $tempPath -Force

# Get root folder from ZIP
$extractedFolder = Get-ChildItem $tempPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1

if (-not $extractedFolder) {
    Write-Host "No folder found inside ZIP"
    exit
}

Write-Host "Extracted folder:" $extractedFolder.Name

# Copy whole folder into repo
$destination = Join-Path $repoPath $extractedFolder.Name

if (Test-Path $destination) {
    Remove-Item $destination -Recurse -Force
}

Copy-Item $extractedFolder.FullName $repoPath -Recurse -Force

# Cleanup temp
Remove-Item $tempPath -Recurse -Force

# Git push
git add .
git commit -m "Auto upload folder from latest zip"
git push

Write-Host "Folder pushed successfully"
