########## XAB-TEMPLATE: INSTALL SCRIPT FOR WINDOWS ##########

$Link = "https://github.com/koalition-xab/xab-template.git"
$Destination = "$env:LOCALAPPDATA\typst\packages\local\xab-template\"
$Version = "1.0.0"

$TargetPath = "$Destination$Version"

Write-Host "Creating directory (if not exists)..."
New-Item -ItemType Directory -Force -Path $TargetPath | Out-Null

Write-Host "Cloning repository..."
git clone $Link $TargetPath
cd xab-template
git submodule init
git submodule update

Write-Host "Done."
