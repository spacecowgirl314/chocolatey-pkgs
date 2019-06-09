$ErrorActionPreference = 'Stop'

$toolsDir      = Split-Path $MyInvocation.MyCommand.Definition
$embedded_path = gi "$toolsDir\*_x32.zip"

$packageArgs = @{
    PackageName  = 'lux'
    FileFullPath = $embedded_path
    Destination  = $toolsDir
}
ls $toolsDir\* | ? { $_.PSISContainer } | rm -Recurse -Force #remove older package dirs
Get-ChocolateyUnzip @packageArgs
rm $toolsDir\*.zip -ea 0
