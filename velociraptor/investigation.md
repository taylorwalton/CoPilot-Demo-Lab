# Velociraptor Investigation — Download-Cradle Chain

The alerts told you *actions* happened — a download, an execution, a registry write.
They did not tell you the current state of the box: what landed, whether it ran,
and whether it's lying about what it is. That's what you collect here.

Run these from CoPilot (Velociraptor artifacts against the host) or directly in Velociraptor.

---

## 1. `Windows.Search.FileFinder` — what did this actually drop?

Point it at `C:\Users\Public\` and pull everything created recently.

**Why:** the alert flagged one downloaded file. It never mentioned `svchost_helper.exe`
or `loot.txt` that stage2 dropped. This shows the full set of files this incident put
on disk.

---

## 2. `Windows.Forensics.Prefetch` + `Windows.System.Amcache` — did it run?

**Why:** finding a file proves it's there. These prove it *executed*, and when.
"Downloaded but never run" and "downloaded and executed" are different severities.

---

## 3. `Windows.System.PowerShell` — is this binary lying about what it is?

Velociraptor running PowerShell live on the endpoint (same mechanism a CoPilot Action
uses). Collection command:

```powershell
# what is this thing, really?
Get-FileHash  C:\Users\Public\svchost_helper.exe -Algorithm SHA256
Get-AuthenticodeSignature C:\Users\Public\svchost_helper.exe | Select-Object Status, SignerCertificate

# everything that landed in the drop folder in the last 15 minutes
Get-ChildItem C:\Users\Public -Recurse |
  Where-Object { $_.CreationTime -gt (Get-Date).AddMinutes(-15) } |
  Select-Object FullName, CreationTime, Length
```

**Why:** the hash + signature check exposes the masquerade — the file comes back
Microsoft-signed (it's a copied notepad) but it's sitting in `C:\Users\Public` under a
service name. Signed, but not what it claims to be.

---

## 4. Run-key / autoruns — did they set up to come back?

Use the `Windows.Persistence.*` / autoruns artifacts, or the live-PowerShell path:

```powershell
Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
```

**Why:** the `SvcHelper` value points right back at the planted binary. It relaunches at
every logon until you remove it — so you rip out the persistence, not just the file.
