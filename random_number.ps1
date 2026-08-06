param(
    [int]$Minimum = 1,
    [int]$Maximum = 100,
    [ValidateRange(1, 1000000)]
    [int]$Count = 1,
    [string]$Memo = "",
    [switch]$NonInteractive
)

function Read-IntegerSetting {
    param(
        [string]$Label,
        [int]$Default,
        [int]$Lowest = [int]::MinValue,
        [int]$Highest = [int]::MaxValue
    )

    while ($true) {
        $response = Read-Host "$Label [$Default]"

        if ([string]::IsNullOrWhiteSpace($response)) {
            return $Default
        }

        $parsed = 0
        if ([int]::TryParse($response, [ref]$parsed) -and
            $parsed -ge $Lowest -and $parsed -le $Highest) {
            return $parsed
        }

        if ($Lowest -eq [int]::MinValue -and $Highest -eq [int]::MaxValue) {
            Write-Host "Please enter a whole number."
        }
        else {
            Write-Host "Please enter a whole number from $Lowest through $Highest."
        }
    }
}

if (-not $NonInteractive) {
    $Minimum = Read-IntegerSetting -Label "Minimum" -Default $Minimum

    while ($true) {
        $enteredMaximum = Read-IntegerSetting -Label "Maximum" -Default $Maximum
        if ($enteredMaximum -ge $Minimum) {
            $Maximum = $enteredMaximum
            break
        }
        Write-Host "Maximum must be greater than or equal to Minimum ($Minimum)."
    }

    $Count = Read-IntegerSetting -Label "Count" -Default $Count -Lowest 1 -Highest 1000000

    if ([string]::IsNullOrWhiteSpace($Memo)) {
        $enteredMemo = Read-Host "Memo (optional)"
    }
    else {
        $enteredMemo = Read-Host "Memo (optional) [$Memo]"
    }

    if (-not [string]::IsNullOrWhiteSpace($enteredMemo)) {
        $Memo = $enteredMemo
    }
}

if ($Minimum -gt $Maximum) {
    throw "Minimum must be less than or equal to Maximum."
}

$numbers = @(
    for ($index = 0; $index -lt $Count; $index++) {
        if ($Minimum -eq $Maximum) {
            $Minimum
        }
        else {
            # Get-Random treats Maximum as exclusive, so add one to include it.
            Get-Random -Minimum $Minimum -Maximum ([long]$Maximum + 1)
        }
    }
)

$timestamp = [DateTimeOffset]::Now.ToString("yyyy-MM-ddTHH:mm:ss.fffzzz")
$logPath = Join-Path $PSScriptRoot "random_number.log"
$joinedResults = $numbers -join ","
$logLines = @("[$timestamp] count=$Count range=$Minimum..$Maximum results=$joinedResults")

if (-not [string]::IsNullOrWhiteSpace($Memo)) {
    $oneLineMemo = ($Memo -replace "[\r\n\t]+", " ").Trim()
    $logLines += "memo: $oneLineMemo"
}

Add-Content -LiteralPath $logPath -Value $logLines -Encoding UTF8

# Write-Output $numbers
