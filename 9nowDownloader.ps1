[System.Collections.ArrayList]$seasonURLs = @()
$WebDriverDirectory = ".\"
$showList = Get-Content -Path ".\showlist.csv"

$downloadHistory = [ordered]@{}
$downloadHistoryJSON = Get-Content -Raw -Path ".\downloadHistory.json" | ConvertFrom-Json
$downloadHistoryJSON.psobject.properties | ForEach-Object { $downloadHistory[$_.Name] = $_.Value }

if ( $null -eq $downloadHistory) {
    "Download History is empty. Recreating file"
    $downloadHistory = [ordered]@{}
}

$Driver = Start-SeChrome -WebDriverDirectory $WebDriverDirectory -Headless
Enter-SeUrl "https://www.9now.com.au/" -Driver $Driver

$showList | ForEach-Object {
    $showURL = $_
    Write-Host "SHowURL = "    $showURL
    Enter-SeUrl $showURL -Driver $Driver
    $links = Get-SeElement -By TagName -TagName 'a' -Driver $Driver | Where-Object { $_.GetAttribute("href") -match $showURL -and $_.GetAttribute("href").Length -lt ($showURL.Length + 12) }
    $showName = (Get-SeElement -By TagName -TagName 'h2' -Driver $Driver).Text
    $showName
    $seasonURLs = @{} # Clear out seasonURLs for previous Show
    $links | ForEach-Object { $seasonURLs.Add( $_.GetAttribute("href")) | Out-Null } # Grab all the urls now, before they become stale.

    $seasonURLs | ForEach-Object {
        $seasonURL = $_
        Write-Host "SeasonURL: " $seasonURL
        Enter-SeUrl $seasonURL -Driver $Driver

        $seasonNum = $seasonURL.Split("/")[-1].Split("-")[-1]
        Write-Host "Season $seasonNum"
        $links = Get-SeElement -By TagName -TagName 'a' -Driver $Driver | Where-Object { $_.GetAttribute("href") -match "episode-" }
        $links | ForEach-Object {
            $episodeURL = $_.GetAttribute("href")
            $episodeURL
            $episodeNum = $episodeURL.Split("/")[-1].Split("-")[-1]
            Write-Host "Episode $episodeNum"
            $episodeRef = $showName + " - S" + $seasonNum + "E" + $episodeNum
            if ( $null -eq $downloadHistory[$episodeRef]) {
                Write-Host "Downloading $episodeRef from: $episodeURL"
                $downloadHistory.Add( $episodeRef , (Get-Date -DisplayHint DateTime))
                Start-Process -FilePath "youtube-dl.exe" -Wait -ArgumentList ("$episodeURL -o " + '"' + $episodeRef + ".mp4" + '"')
            }
            else {
                Write-Host "Episode $episodeRef already downloaded from: $episodeURL"
            }
        }
    }
}

$downloadHistory  | Sort-Object Name | ConvertTo-Json | Out-File ".\downloadHistory.json"
$Driver.Close()
