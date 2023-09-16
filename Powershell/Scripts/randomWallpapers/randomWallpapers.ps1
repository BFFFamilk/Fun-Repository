#! Copyright By BFFFamilk

$Script_Path = $PSScriptRoot
$Wallpaper_JSON_Path = "C:\Users\BFFFamilk\AppData\Local\Packages\12030rocksdanister.LivelyWallpaper_97hta09mmv6hy\LocalCache\Local\Lively Wallpaper\Library\SaveData\wptmp"

function Set-Up {
    Write-Host ">> Checking Components..." -ForegroundColor Red

    if (Test-Path -Path "$Script_Path/Wallpaper.csv") {
        Write-Host ">> Wallpaper.csv already exists" -ForegroundColor Green
    }
    else {
        New-Item -Path $Script_Path -Name "Wallpaper.csv" -ItemType File | Out-Null
        
        Write-Host ">> Wallpaper.csv has been successfully created" -ForegroundColor Yellow
    }
}

function Set-randomWallpapers {
    Write-Host ">> Initializing Function..." -ForegroundColor Yellow
    Get-Content -Path "$Script_Path/Wallpaper.csv" | Select-String -Pattern "ID","Name","Path" -AllMatches | Out-File "$Script_Path/Wallpaper.csv"
    if ([String]::IsNullOrWhiteSpace((Get-Content "$Script_Path/Wallpaper.csv" | Select-Object -First 1))) {
        Set-Content -Path "$Script_Path/Wallpaper.csv" -Value '"ID","Name","Path"'
        Write-Host ">> Set Heading for CSV file successfully" -ForegroundColor Cyan
    }


    $i = 1
    Get-ChildItem -Path "$Wallpaper_JSON_Path" | Select-Object Name | ForEach-Object {
        $JSON_Root = $_.Name
        $JSON_Reader = Get-Content -Path "$Wallpaper_JSON_Path/$JSON_Root/LivelyInfo.json" | ConvertFrom-Json | Select-Object Title, FileName
        
        $Append_Content = [PSCustomObject]@{
            "ID" = $i
            "Name" = $JSON_Reader.Title
            "Path" = $JSON_Reader.FileName
        }
        $Append_Content | Export-Csv -Path "$Script_Path/Wallpaper.csv" -NoTypeInformation -Append

        $i += 1
    }

    $Time_Run = Read-Host ">> Input time to change wallpaper (in seconds)"
    $Time_Remain = 0
    $Time = New-TimeSpan -Seconds $Time_Run
    $Name_Wallpaper = "Waiting for getting name of wallpaper"
    $Percentage = 100

    while ($True) {
        $Random_Max = (Import-Csv -Path "$Script_Path/Wallpaper.csv").Count
        $Random_ID = Get-Random -Minimum 1 -Maximum $Random_Max
        $CSV_R = Import-Csv -Path "$Script_Path/Wallpaper.csv"

        if ($Time -eq 0) {
            livelycu.exe setwp --file $CSV_R.Path[$Random_ID-1]
            
            $Name_Wallpaper = $CSV_R.Name[$Random_ID-1]
            $Time = New-TimeSpan -Seconds $Time_Run
            $Time_Remain = 0
        } else { $Time = $Time - (New-TimeSpan -Seconds 1) }

        # Write-Host $Time_Run $p
        Write-Progress -Activity ">> Current: $Name_Wallpaper |"  -Status "Changing random in " -PercentComplete $Percentage -SecondsRemaining ($Time_Run - $Time_Remain)
        
        $Time_Remain++
        Start-Sleep -Duration (New-TimeSpan -Seconds 1)
    }
}

function Render {
    Clear-Host
    Write-Host "
---------------------------------------------------------------------------------------------
____                 _                  __        __    _ _                                 
|  _ \ __ _ _ __   __| | ___  _ __ ___   \ \      / __ _| | |_ __   __ _ _ __   ___ _ __ ___ 
| |_) / _` | '_ \ / _` |/ _ \| '_ ` _ \   \ \ /\ / / _` | | | '_ \ / _` | '_ \ / _ | '__/ __|
|  _ | (_| | | | | (_| | (_) | | | | | |   \ V  V | (_| | | | |_) | (_| | |_) |  __| |  \__ \
|_| \_\__,_|_| |_|\__,_|\___/|_| |_| |_|    \_/\_/ \__,_|_|_| .__/ \__,_| .__/ \___|_|  |___/
                                                            |_|         |_|                  
---------------------------------------------------------------------------------------------" -ForegroundColor Green

    
}

function Main {
    Render
    Set-Up
    Set-randomWallpapers
}

Main