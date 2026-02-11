$downloadsPath = "$env:USERPROFILE\Downloads"
$repoPath = $PSScriptRoot
$tempPath = "$repoPath\_temp"

# 1. Latest ZIP find karo
$zip = Get-ChildItem $downloadsPath -Filter *.zip |
       Sort-Object LastWriteTime -Descending |
       Select-Object -First 1

if (-not $zip) {
    Write-Host "❌ Downloads folder me koi ZIP nahi mili"
    exit
}

Write-Host "✅ Latest ZIP:" $zip.Name

# 2. Temp folder clean banao
if (Test-Path $tempPath) {
    Remove-Item $tempPath -Recurse -Force
}
New-Item -ItemType Directory $tempPath | Out-Null

# 3. Unzip
Expand-Archive $zip.FullName $tempPath -Force

# 4. Extracted files repo me copy karo
Get-ChildItem $tempPath | ForEach-Object {
    Copy-Item $_.FullName $repoPath -Recurse -Force
}

# 5. Temp cleanup
Remove-Item $tempPath -Recurse -Force

# 6. Git push
git status
git add .
git commit -m "Auto upload latest zip"
git push

Write-Host "🚀 GitHub push successful"
