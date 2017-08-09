# ==============================================================================
# Windows Update .msu Install Script for different check
# ------------------------------------------------------------------------------
# Created 07.2017
#   Lukas Friedl (lukas@friedl.li)
# 
# ==============================================================================

$update_arr = @{}
$update_file = Get-content C:\tmp\Update-Diff.txt
$file = "C:\tmp\Update-Files.txt"
$quiet_install = 0

$quiet_install = Read-Host -Prompt 'Sollen die Updates mit der Quiet Methode installiert werden? Wenn Ja -> 0 / falls nicht -> 1'

#---------- Get Windows Version from Server ----------

$version_file = "C:\tmp\vs.txt"

(reg.exe query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName | Select-Object -Skip 2) | Set-Content $version_file

$win_version = Get-Content $version_file

for($i = 0; $i -le 1; $i++) {
    $win_version = $win_version.Get($i).Substring(37)
    $win_version = $win_version.Replace(" ", "-")
    $win_version = $win_version.Trim()
}

$win_version_updates = "WS" + $win_version + "-Updates"
$win_version_updates

Remove-Item C:\tmp\vs.txt
cls

#---------- Check if the tmp Directory is existing ----------

if((Test-Path C:\tmp\Update-Files.txt) -eq $True) {
    Remove-Item C:\tmp\Update-Files.txt
    New-Item -Path C:\tmp -Name Update-Files.txt -ItemType file
} else {
    New-Item -Path C:\tmp -Name Update-Files.txt -ItemType file
}

#---------- Copy the content from the update-File to an Hashtable ----------

foreach($update_line in $update_file) {
    
    $update_string = $update_line.SubString(0,8)
    $update_string = $update_string.Trim()
    
    $update_arr.Add($update_string,$update_line)
    
    cls
}
$update_arr

#---------- Read the existing files in directory C:\tmp\Updates and write it to file ----------

[String] $folder="C:\tmp\$win_version_updates";
$file_names = Get-ChildItem -Path $folder | SELECT Name
$file_names >> C:\tmp\Update-Files.txt

#---------- First 3 Lines in the file will be skipped ----------

(Get-Content $file | Select-Object -Skip 3) | Set-Content $file
$file = Get-Content $file

#---------- Check if installing is possible ----------

if($file.Count -eq 0) {
    Remove-Item C:\tmp\Update-Files.txt
} else {

    cls
    
    for($i = 0; $i -lt $file.Length; $i++) {
        
        $file_msu_full = $file.Get($i)
        $file_okb = $file_msu_full.Substring($file_msu_full.IndexOf("KB")+2,7)
        $file_okb = $file_okb.Trim("-")
        $file_msu_full
        $file_okb
        
        if($update_arr.ContainsKey($file_okb) -eq $true) {
            if($quiet_install -eq 0) {
                wusa.exe $file_msu_full/quiet
                "The Update " +  $file_msu_full + "`ris successfully installed!"
            } else {
                wusa.exe $file_msu_full
                "The Update " +  $file_msu_full + "`ris successfully installed!"
            }
        } else {
            "Benötigtes Update nicht im Update Ordner vorhanden!"
        }
        
    }
        
}
Remove-Item C:\tmp\Update-Files.txt

$file

"Finished!"