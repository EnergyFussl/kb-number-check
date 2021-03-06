# ==============================================================================
# Windows Update .msu Install Script for different check
# ------------------------------------------------------------------------------
# Created 07.2017
#   Lukas Friedl (lukas@friedl.li)
# 
# ==============================================================================

$update_arr = @{}
$update_file = Get-content ./Report_missing_Updates.txt
$file = "./Update-Files.txt"
$quiet_install = 0
$directory_check = 0
Remove-Item ./Update-Files.txt

#---------- Get Windows Version from Server ----------

$version_file = "./vs.txt"

(reg.exe query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName | Select-Object -Skip 2) | Set-Content $version_file

$win_version = Get-Content $version_file

for($i = 0; $i -le 1; $i++) {

    if($win_version.Get($i).Length -eq 60){
        $win_version = $win_version.Get($i).Substring(37,14)
        $win_version = $win_version.Replace(" ", "-")
        $win_version = $win_version.Trim()
    } elseif($win_version.Get($i).Length -eq 62) {
        $win_version = $win_version.Get($i).Substring(37,14)
        $win_version = $win_version.Replace(" ", "-")
        $win_version = $win_version.Trim()
    }   
}

$win_version_updates = "WS" + $win_version + "-Updates"

Remove-Item ./vs.txt
cls

#---------- Ask the User ----------

if($win_version.Equals("Server-2012-R2") -eq $true) {
    $directory_check = Read-Host -Prompt 'Ist der Ordner mit den Updates bereits unter ./WSServer-2012-R2-Updates? Wenn Ja -> 0 / falls nicht -> 1'
}

if($win_version.Equals("Server-2008-R2") -eq $true) {
    $directory_check = Read-Host -Prompt 'Ist der Ordner mit den Updates bereits unter ./WSServer-2008-R2-Updates? Wenn Ja -> 0 / falls nicht -> 1'
}

if ($directory_check -eq 0){ }
else
{
     Write-Host "Script Stopped!"
     Break
}

$quiet_install = Read-Host -Prompt 'Sollen die Updates mit der Quiet Methode installiert werden? Wenn Ja -> 0 / falls nicht -> 1'

#---------- Copy the content from the update-File to an Hashtable ----------

foreach($update_line in $update_file) {

    $update_string = $update_line.SubString(0,8)
    $update_string = $update_string.Trim()
    
    $update_arr.Add($update_string,$update_line)
    
    cls
}

#---------- Read the existing files in directory C:\tmp\Updates and write it to file ----------

[String] $folder="./$win_version_updates";
$file_names = Get-ChildItem -Path $folder | SELECT Name
$file_names >> ./Update-Files.txt

#---------- First 3 Lines in the file will be skipped ----------

(Get-Content $file | Select-Object -Skip 3) | Set-Content $file
$file = Get-Content $file

#---------- Check if installing is possible ----------

if($file.Count -eq 0) {
    Remove-Item ./Update-Files.txt
    "Keine .msu File im Update Ordner $win_version_updates vorhanden!"
    break
} else {

    cls
    
    for($i = 0; $i -lt $file.Length; $i++) {
    
        $file_msu_full = $file.Get($i)
        if($file_msu_full.LastIndexOf("kb") -eq -1) {
            $file_okb = $file_msu_full.Substring($file_msu_full.IndexOf("KB")+2,7)
            $file_okb = $file_okb.Trim("-")
        }

        if($file_msu_full.LastIndexOf("KB") -eq -1) {
            $file_okb = $file_msu_full.Substring($file_msu_full.IndexOf("kb")+2,7)
            $file_okb = $file_okb.Trim("-")
        }
        
        if($update_arr.ContainsKey($file_okb) -eq $true) {
            if($quiet_install -eq 0) {
                
                $proc = Get-Process | Where-Object {$_.ProcessName -eq "wusa"}
                
                do{
                    $proc = Get-Process | Where-Object {$_.ProcessName -eq "wusa"}
                }while($proc -imatch 'wusa')
                
                wusa.exe ./$win_version_updates\$file_msu_full /quiet /norestart
                "The Update " +  "KB" + $file_okb + " `ris installing!"
                    
            } else {
                $proc = Get-Process | Where-Object {$_.ProcessName -eq "wusa"}
                
                do{
                    $proc = Get-Process | Where-Object {$_.ProcessName -eq "wusa"}
                }while($proc -imatch 'wusa')
                
                wusa.exe ./$win_version_updates\$file_msu_full
                "The Update " +  "KB" + $file_okb + " `ris installing!"
                
            }
        }
  }
  Remove-Item ./Update-Files.txt 
}

"Finished!"