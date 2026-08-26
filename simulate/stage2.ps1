# ============================================================================
# stage2.ps1  —  BENIGN lab second-stage payload (SOCFortress CoPilot demo)
# ----------------------------------------------------------------------------
# This is the "downloaded payload" in a download-cradle simulation. It does
# NOTHING harmful. It copies a signed Windows binary into a user-writable path
# under a fake service name (to demo masquerading), stages a placeholder file,
# and sets a Run-key for persistence — all so a SOC analyst can practice
# discovering it with Velociraptor.
#
# LAB USE ONLY. Run only on a machine you own and intend to investigate.
# ============================================================================

$drop = "C:\Users\Public\svchost_helper.exe"

# Masquerade: a Microsoft-signed binary (notepad) planted in a public folder
# under a service-sounding name. Signed, but absolutely not where it belongs.
Copy-Item "C:\Windows\System32\notepad.exe" $drop -Force

# Fake "collected data" staging file
Set-Content -Path "C:\Users\Public\loot.txt" -Value "staged data placeholder - lab only"

# Persistence: Run key so the planted binary launches at every logon (T1547.001)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
  -Name "SvcHelper" -Value $drop

# Execution marker so you can confirm stage2 actually ran
"stage2 executed $(Get-Date -Format o)" | Out-File "C:\Users\Public\stage2_ran.txt"

Write-Host "[stage2] benign payload deployed. Now go investigate with Velociraptor." -ForegroundColor Yellow
