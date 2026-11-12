# Subdomain Finder V1.0

A lightweight PowerShell subdomain discovery tool that queries the [CertSpotter Certificate Transparency API](https://api.certspotter.com/) and exports discovered DNS names to TXT and CSV files.

> **Scope and authorization:** Use this tool only for domains you own or are explicitly authorized to assess. Certificate Transparency data is passive discovery data; it does not prove that a hostname is currently active or reachable.

## Features

- Accepts a target domain at runtime — the script is not hardcoded to one organization or domain.
- Queries CertSpotter for certificate issuance records and DNS names.
- Includes the target apex domain and its subdomains.
- Normalizes hostnames to lowercase and removes trailing dots.
- Deduplicates discovered hostnames.
- Saves results as a TXT file and a CSV file.
- Displays discovered hostnames and a result summary.
- Uses PowerShell's built-in `Invoke-RestMethod`; no third-party PowerShell modules are required.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+
- Internet access to reach `api.certspotter.com`
- Permission to perform reconnaissance on the target domain

No API key is configured in this V1 script. API availability, rate limits, and response behavior are controlled by CertSpotter and may change.

## Files

Keep the script and its README in the same working folder, for example:

```text
SubdomainFinder/
├── SubdomainFinder.ps1
└── README.md
```

## Installation

1. Create a folder named `SubdomainFinder`.
2. Save the PowerShell script as `SubdomainFinder.ps1`.
3. Save this guide as `README.md` in the same folder.
4. Open PowerShell in that folder.

## Run the tool

From the tool folder, run:

```powershell
.\SubdomainFinder.ps1
```

If PowerShell blocks script execution, you can allow scripts for the current PowerShell process only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then run the script again:

```powershell
.\SubdomainFinder.ps1
```

This execution-policy change applies only to the current PowerShell process; it does not permanently change the machine's policy.

## Enter a target domain

When prompted, enter a domain name without a path, for example:

```text
example.com
```

Other examples:

```text
acme.in
example.org
sub.example.com
```

The script uses the entered value to build the CertSpotter API request. It is not limited to `tracxn.com` or any other hardcoded domain.

**Important:** Enter the registered/root domain when you want discovery across the domain and its subdomains. Entering a subdomain asks CertSpotter about that subdomain's namespace, rather than automatically expanding to the parent domain.

The V1 script also accepts a URL-like input such as `https://example.com/` because it strips the scheme and path before validation. For the most reliable input, use only the domain name.

## Output

The script creates two files in the current working directory:

| File                      | Contents                            |
| ------------------------- | ----------------------------------- |
| `<domain>-subdomains.txt` | One discovered hostname per line    |
| `<domain>-subdomains.csv` | A CSV file with a `Hostname` column |

For example, when the target is `example.com`, the output files are:

```text
example.com-subdomains.txt
example.com-subdomains.csv
```

The TXT file can be opened in Notepad. The CSV file can be opened in Excel or imported into other tools.

If no hostnames are returned, the script still creates an empty TXT file and a CSV containing the `Hostname` header.

## Understanding the results

- **Discovered hostname:** A DNS name found in the DNS names returned by CertSpotter for matching certificate issuance records.
- **Unique hostname:** Duplicate entries are removed before saving.
- **Total hostnames:** The number of unique names in the final output, including the apex/root domain if CertSpotter returns it.
- **Not a live-host check:** V1 does not resolve DNS, test HTTP/HTTPS, scan ports, or verify whether a hostname is currently reachable.

Certificate Transparency coverage is not a complete asset inventory. A hostname may be missing if it has not appeared in the records returned by the API. A certificate name can also refer to a hostname whose DNS record or service is no longer active. Wildcard entries such as `*.example.com` may appear; they represent certificate coverage, not a separately verified live host.

## Troubleshooting

### Invalid domain format

Enter a valid DNS domain such as `example.com`. Avoid entering an IP address, email address, or a full URL with query parameters.

### API request failed / timeout

- Check that the system has internet access.
- Try opening `https://api.certspotter.com/` in a browser to confirm basic connectivity.
- Retry later if the service is unavailable or rate-limiting requests.
- Check that a corporate proxy or firewall is not blocking the request.

### No hostnames discovered

- Confirm the domain spelling.
- Try the registered/root domain.
- Remember that CertSpotter only returns names represented in the certificate records it can access; no result does not prove that no subdomains exist.

### Output files are not where expected

The script writes files to the PowerShell **current working directory**, not necessarily the directory where the script is stored. Run it from the tool folder, or check the folder shown by:

```powershell
Get-Location
```

## Limitations in V1

- CertSpotter is the only discovery source.
- No brute-force or wordlist-based enumeration.
- No DNS resolution or live-host verification.
- No HTTP status checks, screenshots, port scans, or vulnerability tests.
- API results depend on CertSpotter coverage, availability, and rate limits.

## Responsible use

Only assess domains that you own or have explicit written authorization to test. Follow the scope, rate limits, and rules of engagement for each assessment. Treat discovered hostnames as leads for authorized validation, not as permission to probe them.
