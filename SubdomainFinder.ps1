Clear-Host

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "           SUBDOMAIN FINDER V1.0" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Cyan

# Get target domain
$domain = Read-Host "`n[+] Enter Target Domain"

# Normalize input
$domain = $domain.Trim().ToLower()
$domain = $domain -replace '^https?://', ''
$domain = $domain.TrimEnd('/')
$domain = $domain.Split('/')[0]

# Validate domain
if ($domain -notmatch '^(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$') {
    Write-Host "`n[!] Invalid domain format!" -ForegroundColor Red
    exit
}

# CertSpotter API
$encodedDomain = [uri]::EscapeDataString($domain)

$url = "https://api.certspotter.com/v1/issuances?domain=$encodedDomain&include_subdomains=true&expand=dns_names"

# Output files
$txtFile = ".\$domain-subdomains.txt"
$csvFile = ".\$domain-subdomains.csv"

Write-Host "`n[*] Target Domain : $domain" -ForegroundColor Yellow
Write-Host "[*] Source        : CertSpotter API"
Write-Host "[*] Fetching subdomains...`n" -ForegroundColor Cyan

try {

    # API Request
    $data = Invoke-RestMethod `
        -Uri $url `
        -Method Get `
        -Headers @{ "Accept" = "application/json" } `
        -TimeoutSec 30 `
        -ErrorAction Stop

    # Extract DNS names
    $hosts = @(
        foreach ($issuance in $data) {
            foreach ($hostname in $issuance.dns_names) {

                if ($hostname) {

                    $hostname = $hostname.Trim().ToLower().TrimEnd('.')

                    # Include only target domain and its subdomains
                    if (
                        $hostname -eq $domain -or
                        $hostname.EndsWith(".$domain")
                    ) {
                        $hostname
                    }
                }
            }
        }
    ) | Sort-Object -Unique

    # Save TXT output
    $hosts | Set-Content -Path $txtFile -Encoding UTF8

    # Save CSV output
    if ($hosts.Count -gt 0) {

        $hosts |
        ForEach-Object {
            [PSCustomObject]@{
                Hostname = $_
            }
        } |
        Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
    }
    else {
        "Hostname" | Set-Content -Path $csvFile -Encoding UTF8
    }

    # Display results
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "             DISCOVERED HOSTNAMES" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Cyan

    if ($hosts.Count -gt 0) {

        $hosts | ForEach-Object {
            Write-Host "[+] $_" -ForegroundColor Green
        }

    }
    else {
        Write-Host "[!] No hostnames discovered." -ForegroundColor Yellow
    }

    # Summary
    Write-Host "`n==============================================" -ForegroundColor Cyan
    Write-Host "[+] Total Hostnames : $($hosts.Count)" -ForegroundColor Green
    Write-Host "[+] TXT Output      : $txtFile" -ForegroundColor Yellow
    Write-Host "[+] CSV Output      : $csvFile" -ForegroundColor Yellow
    Write-Host "==============================================" -ForegroundColor Cyan

}
catch {

    Write-Host "`n[!] API Request Failed!" -ForegroundColor Red
    Write-Host "[!] Error: $($_.Exception.Message)" -ForegroundColor Red

}
