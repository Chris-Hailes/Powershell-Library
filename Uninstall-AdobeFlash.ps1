$ErrorActionPreference = 'Stop'
try
{
$url = 'http://download.macromedia.com/get/flashplayer/current/support/uninstall_flash_player.exe'
$file = "$env:SystemRoot\TEMP\uninstall_flash_player.exe"
$client = New-Object System.Net.WebClient
$client.DownloadFile($url, $file)
    cmd /c $file -uninstall
}
catch
{
Write-Output $_ | Out-File $env:SystemRoot\Temp\flash_uninstall.log
}