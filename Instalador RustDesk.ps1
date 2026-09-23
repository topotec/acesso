$ErrorActionPreference= 'silentlycontinue'

# Assign the value random password to the password variable
$rustdesk_pw=(-join ((65..90) + (97..122) | Get-Random -Count 12 | % {[char]$_}))

# Get your config string from your Web portal and Fill Below
$rustdesk_cfg="0nIt92YuEWan9Gbv52YlR3bw9GduIXYv8iOzBHd0hmI6ISawFmIsISPFdHM3l2RnNmVTh2NDdTMPVEcrcFWhF3N1FWOyw2ZmNGUqdXdQRUU35EREJiOikXZrJCLi02bj5SYpd2bs9mbjVGdvB3b05ichJiOikXYsVmciwiIt92YuEWan9Gbv52YlR3bw9GduIXYiojI0N3boJye"

################################### Please Do Not Edit Below This Line #########################################
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Host "Reabrindo o PowerShell como Administrador..."
    Start-Process powershell `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}


# Checks for the latest version of RustDesk
$url = 'https://www.github.com//rustdesk/rustdesk/releases/latest'
$request = [System.Net.WebRequest]::Create($url)
$response = $request.GetResponse()
$realTagUrl = $response.ResponseUri.OriginalString
$RDLATEST = $realTagUrl.split('/')[-1].Trim('v')
echo "RustDesk $RDLATEST is the latest version."

# Checks the version of RustDesk installed.
$rdver = ((Get-ItemProperty  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RustDesk\").Version)

# Skips to inputting the configuration if the latest version of RustDesk is already installed.
if($rdver -eq "$RDLATEST") {
echo "RustDesk $rdver is already installed."
cd $env:ProgramFiles\RustDesk
echo "Inputting configuration now."
.\rustdesk.exe --config $rustdesk_cfg
.\rustdesk.exe --password $rustdesk_pw
$rustdesk_id = .\rustdesk.exe --get-id | Write-Output -OutVariable rustdesk_id
echo "All done! Please double check the Network settings tab in RustDesk."
echo ""
echo "..............................................."
# Show the value of the ID Variable
echo "RustDesk ID: $rustdesk_id"

# Show the value of the Password Variable
echo "Password: $rustdesk_pw"
echo "..............................................."
echo ""
echo "Press Enter to open RustDesk."
pause
.\rustdesk.exe
exit
}

if (!(Test-Path C:\Temp)) {
  New-Item -ItemType Directory -Force -Path C:\Temp > null
}

cd C:\Temp
echo "Downloading RustDesk version $RDLATEST."
powershell Invoke-WebRequest "https://github.com/rustdesk/rustdesk/releases/download/$RDLATEST/rustdesk-$RDLATEST-x86_64.exe" -Outfile "rustdesk.exe"
echo "Installing RustDesk version $RDLATEST."
Start-Process .\rustdesk.exe --silent-install
Start-Sleep -Seconds 10

$ServiceName = 'rustdesk'
$arrService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($arrService -eq $null)
{
    echo "Installing service."
    cd $env:ProgramFiles\RustDesk
    Start-Process .\rustdesk.exe --install-service -wait -Verbose
    Start-Sleep -Seconds 20
}

while ($arrService.Status -ne 'Running')
{
    Start-Service $ServiceName
    Start-Sleep -seconds 5
    $arrService.Refresh()
}

# Waits for installation to complete before proceeding.
echo "Please wait a few seconds."
Start-Sleep -Seconds 10

cd $env:ProgramFiles\RustDesk
echo "Inputting configuration now."
.\rustdesk.exe --config $rustdesk_cfg
.\rustdesk.exe --password $rustdesk_pw
$rustdesk_id = .\rustdesk.exe --get-id | Write-Output -OutVariable rustdesk_id
echo "All done! Please double check the Network settings tab in RustDesk."
echo ""
echo "..............................................."
# Show the value of the ID Variable
echo "RustDesk ID: $rustdesk_id"

# Show the value of the Password Variable
echo "Password: $rustdesk_pw"
echo "..............................................."
echo ""
echo "Press Enter to open RustDesk."
pause
.\rustdesk.exe
