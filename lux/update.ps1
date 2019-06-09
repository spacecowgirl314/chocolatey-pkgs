import-module au

$releases = 'https://github.com/cybercatgurrl/lux/releases'

function global:au_SearchReplace {
   @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*packageName\s*=\s*)('.*')"  = "`$1'$($Latest.PackageName)'"
        }

        "$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`$2"
        }

        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+x32:).*"            = "`${1} $($Latest.URL32)"
          "(?i)(checksum32:).*"        = "`${1} $($Latest.Checksum32)"
        }
    }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge }

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

    $re    = 'lux-.*\.zip$'
    $url   = $download_page.links | ? href -match $re | select -First 2 -expand href | % { 'https://github.com' + $_ }

    $version  = $url -split '/' | select -Last 1 -Skip 1

    @{
        Version      = $version -replace '^.'
        URL32        = $url | select -First 1
        ReleaseNotes = "https://github.com/cybercatgurrl/lux/releases/tag/${version}"
    }
}

update -ChecksumFor none
