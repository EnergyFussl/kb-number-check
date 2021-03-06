# ==============================================================================
# Write differents of two existing files (Soll und Ist) in installed Updates File and missing Updates File
# ------------------------------------------------------------------------------
# Created 07.2017
#   Lukas Friedl (lukas@friedl.li)
# 
# ==============================================================================

cls
$s_arr = @()
$i_arr = @{}
$update_arr = @{}
$is_soll_current = 0

#---------- Remove Update Files ----------

Remove-Item ./Report_installed_Updates.txt
Remove-Item ./Report_missing_Updates.txt

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

Remove-Item ./vs.txt
cls

#---------- Ask the User ----------

$is_soll_current = Read-Host -Prompt 'Ist Soll-Liste aktuell? Wenn aktuell -> 0 / falls nicht -> 1'

if ($is_soll_current -eq 0){ }
else
{
     Write-Host "Script Stopped!"
     Break
}

#---------- Get current installed updates ----------

$ist_file_name = "WS" + $win_version + "-Ist"
$ist_file_name
WMIC QFE LIST >> ./Report_installed_Updates.txt

#---------- Copy the content from the ist-File to an Hashtable ----------

$i_file = Get-content ./Report_installed_Updates.txt

foreach($i_line in $i_file) {
    
    if($i_line.LastIndexOf("KB") -eq -1) {
        
    } else {
        
        $i_string = $i_line.SubString($i_line.LastIndexOf("KB"), 12)
        $i_string = $i_string.Trim()
        
        if(($i_string -match "KB\d{1}") -eq $True) {
            
            $i_okb = $i_string.Substring(2)
            $i_okb = $i_okb.Trim()
            $i_arr.Add($i_okb,$i_line)
        }
    }

    cls
}

#---------- Copy the content from the soll-File to an Normal Array ----------

$win_version_files = "WS" + $win_version

if($win_version_files -eq "WSServer-2012-R2") {
    $s_file = Get-content ./KB-SOLL-WS2012R2.txt
} elseif($win_version_files -eq "WSServer-2008-R2") {
    $s_file = Get-content ./KB-SOLL-WS2008R2.txt
}

if(($win_version_files -ne "WSServer-2012-R2") -or ($win_version_files -eq "WSServer-2008-R2")) {
    "Non Supported Server Version!"
}

foreach ($s_line in $s_file)
{
    if(($s_line.LastIndexOf("#") -eq 0) -or ($s_line.Length -le 6)) {

    } else {
        
        $s_string = $s_line.Substring(0,8)
        $s_string = $s_string.Trim()
        
        if(($s_string -match "\w") -eq $true) {
            $s_arr += $s_line 
        }        
    }     
}

cls

"Working"

#---------- Check if any Updates already installed ----------

for($i = 0; $i -lt $s_arr.Length; $i++) {

    $s_get_full = $s_arr.Get($i)

    $string_s = $s_get_full.Substring(0,8)
    $string_s = $string_s.Trim()

    for($j = 0; $j -lt ($i_Arr.Count); $j++) {

        if($i_arr.Contains($string_s) -eq $true) {
            
        } else {

            if($i_arr.ContainsValue($s_get_full) -eq $false) {
                $update_arr.Set_Item($string_s,$s_get_full)
            }
        }
    }
}

#---------- Write the missing Updates to a .txt File ----------

$update_arr.Values >> ./Report_missing_Updates.txt
Write-Host "Finish!`n"