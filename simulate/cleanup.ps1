# cleanup.ps1 — remove everything the demo chain created. LAB ONLY.
Remove-Item "C:\Users\Public\svchost_helper.exe","C:\Users\Public\loot.txt",`
  "C:\Users\Public\stage2.ps1","C:\Users\Public\stage2_ran.txt" `
  -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
  -Name "SvcHelper" -ErrorAction SilentlyContinue
Write-Host "[cleanup] demo artifacts removed." -ForegroundColor Green
