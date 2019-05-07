import-module au

$releases = 'https://github.com/wustho/epr/releases'

function global:au_SearchReplace {
   @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*packageName\s*=\s*)('.*')"  = "`$1'$($Latest.PackageName)'"
        }

        "$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`$2"
        }

        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+x64:).*"            = "`${1} $($Latest.URL64)"
          "(?i)(checksum64:).*"        = "`${1} $($Latest.Checksum64)"
        }
    }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge }

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

    $re    = '-win.*\.zip$'
    $url   = $download_page.links | ? href -match $re | select -First 3 -expand href | % { 'https://github.com' + $_ }

    $version  = $url -split '/' | select -Last 1 -Skip 1

    # Fix for 2.2.7b. Hopefully this won't be necessary going forward.
    $urlFix = ""
    if ($version -match "2.2.7") {
        $urlFix = $url -notmatch 'md' | select -First 1 -Skip 1
    } else {
        $urlFix = $url -notmatch 'md' | select -First 1
    }

    @{
        Version      = $version -replace '^.'
        URL64        = $urlFix
        ReleaseNotes = "https://github.com/wustho/epr/releases/tag/${version}"
    }
}

update -ChecksumFor none
