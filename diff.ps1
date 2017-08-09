# ==============================================================================
# Write differents of two existing files (Soll und Ist) in a new file
# ------------------------------------------------------------------------------
# Created 07.2017
#   Lukas Friedl (l.friedl@conova.com)
# 
# ==============================================================================
cls
$s_arr = @()
$i_arr = @{}
$update_arr = @{}
$is_soll_current = 0
$is_soll_place = 0

#---------- Check if the tmp Directory is existing ----------

if((Test-Path C:\tmp -pathType container) -eq $True) {   
    Remove-Item C:\tmp\Update-Diff.txt
    Remove-Item C:\tmp\Updated-Ist.txt
} else {    
    New-Item -Path "C:\" -Name "tmp" -ItemType directory | Out-Null
    Remove-Item C:\tmp\Update-Diff.txt
    Remove-Item C:\tmp\Updated-Ist.txt
}

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


#---------- Is is-File in the correct folder ----------

$win_version_files = "WS" + $win_version
<#
if(($win_version_files -eq "WS2012-R2-Standard") -or ($win_version_files -eq "WS2012-R2-Datacenter") ) {
    "Ist Soll-Liste für den Server in C:\tmp\KB-Soll-WS2012R2.txt ? Wenn ja -> 0 / falls nicht -> 1"
    $is_soll_place = Read-Host -Prompt ' '
    if($is_soll_place -eq 0) {
        $s_file = Get-content C:\tmp\KB-SOLL-WS2012R2.txt
        New-Item -Path "C:\tmp\" -Name $win_version_updates -ItemType directory | Out-Null
    } else {
        Write-Host "Script Stopped!"
        Break
    }
} else {     
    "Keine Server Version gefunden!"
    break
}

if(($win_version_files -eq "WS2008-R2-Standard") -or ($win_version_files -eq "WS2008-R2-Datacenter") ) {
    "Ist Soll-Liste für den Server in C:\tmp\KB-Soll-WS2008R2.txt ? Wenn ja -> 0 / falls nicht -> 1"
    $is_soll_place = Read-Host -Prompt ' '
    if($is_soll_place -eq 0) {
        $s_file = Get-content C:\tmp\KB-SOLL-WS2008R2.txt
        New-Item -Path "C:\tmp\" -Name $win_version_updates -ItemType directory | Out-Null
    } else {
        Write-Host "Script Stopped!"
        Break
    }    
} else {     
    "Keine Server Version gefunden!"
    break
}#>


if($win_version_files -eq "WS7-Enterprise") {
    "Ist Soll-Liste für den Server in C:\tmp\KB-Soll-WS7-Enterprice.txt ? Wenn ja -> 0 / falls nicht -> 1"
    $is_soll_place = Read-Host -Prompt ' '
    if($is_soll_place -eq 0) {
        $s_file = Get-content C:\Users\frlu\Desktop\test-soll.txt
        #Remove-Item C:\tmp\$win_version_updates
        New-Item -Path "C:\tmp\" -Name $win_version_updates -ItemType directory | Out-Null
    } else {
        Write-Host "Script Stopped!"
        Break
    }
} else {     
    "Keine Server Version gefunden!"
    break
}



$is_soll_current = Read-Host -Prompt 'Ist Soll-Liste aktuell? Wenn aktuell -> 0 / falls nicht -> 1'

if ($is_soll_current -eq 0){ }
else
{
     Write-Host "Script Stopped!"
     Break
}

#---------- Read all files ----------

#$s_file_ein = Read-Host -Prompt 'Speicherort (Soll-Liste)'

#$s_file = Get-content $s_file_ein

$s_file = Get-content C:\Users\frlu\Desktop\test-soll.txt
$i_file = Get-content C:\Users\frlu\Desktop\test-ist.txt
cls

#---------- Get current installed updates ----------

$ist_file_name = "WS" + $win_version + "-Ist"
$ist_file_name
Remove-Item C:\tmp\$ist_file_name.txt
WMIC QFE LIST >> C:\tmp\$ist_file_name.txt

#---------- Copy the content from the ist-File to an Hashtable ----------

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

#---------- Remove double entries from Ist-File and write it to a new file ----------

for($i = 0; $i -lt $s_arr.Length; $i++) {

    $s_get_full = $s_arr.Get($i)

    $string_s = $s_get_full.Substring(0,8)
    $string_s = $string_s.Trim()

    for($j = 0; $j -lt ($i_Arr.Count); $j++) {

        if($i_arr.Contains($string_s) -eq $true) {
            $i_arr.Remove($string_s)
        } else {

            if($i_arr.ContainsValue($s_get_full) -eq $false) {
                
            }
        }
    }
}

#---------- Write the missing Updates to a .txt File ----------

$update_arr.Values >> C:\tmp\Update-Diff.txt
$i_arr.Values >> C:\tmp\Updated-Ist.txt

Write-Host "`nNeeded Updates was saved to C:\tmp\Updates.txt" -ForegroundColor "Yellow"
Write-Host "Needed Update Files Directory was created C:\tmp\Updates`n" -ForegroundColor "Yellow"
Write-Host "Finish!`n"