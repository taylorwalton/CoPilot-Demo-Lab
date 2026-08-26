# CoPilot Demo Lab — Chained Attack Simulation

Benign, self-contained attack simulations for demonstrating detection and
investigation with the **SOCFortress SIEM stack** — Wazuh + Sysmon for detection,
Velociraptor for live endpoint investigation, and [SOCFortress CoPilot](https://github.com/socfortress/CoPilot)
tying it together.

These simulations back the SOCFortress YouTube walkthrough on how to view,
investigate, and work alerts and cases inside CoPilot.

> ⚠️ **Lab use only.** Everything here is **benign** — no real malware. The
> "payloads" are copies of signed Windows binaries and plain text files. Run
> these **only** on a machine you own and intend to investigate. They exist so
> defenders can practice detection and response, nothing more.

---

## Scenario: Download Cradle → Execute → Drop & Persist

The most common shape of a real intrusion: get a small foothold, phone home, pull
down the real tooling, run it, and set up to come back. The lesson of the demo is
that your **first alert only sees the download** — everything that download *did*
is discovered live on the box with Velociraptor.

| # | Stage | Technique | What the stack sees |
|---|-------|-----------|---------------------|
| 1 | `certutil` downloads a second stage | T1105 Ingress Tool Transfer | Sysmon 1 (process), 22 (DNS), 3 (network), 11 (file create) |
| 2 | PowerShell executes the second stage | T1059.001 PowerShell | Sysmon 1, 4104 (script block) |
| 3 | Second stage drops a masqueraded exe + Run key | T1036 Masquerading, T1547.001 Run Key | Sysmon 11 (file create), 13 (registry) |
| 4 | **Velociraptor** discovers the drop, unmasks it, finds persistence | — | live host state |

---

## Run it

On the Windows lab endpoint (elevated PowerShell). If Defender is aggressive in
your lab, exclude `C:\Users\Public` first.

```powershell
# option A — one shot
irm https://raw.githubusercontent.com/socfortress1/CoPilot-Demo-Lab/main/simulate/run-chain.ps1 | iex

# option B — clone and run
git clone https://github.com/socfortress1/CoPilot-Demo-Lab
cd CoPilot-Demo-Lab\simulate
.\run-chain.ps1
```

`run-chain.ps1` downloads `stage2.ps1` from this repo via a `certutil` cradle, then
executes it. `stage2.ps1` drops the benign masqueraded binary and sets the Run key.

Clean up afterward:

```powershell
.\simulate\cleanup.ps1
```

---

## Investigate it

See [`velociraptor/investigation.md`](velociraptor/investigation.md) for the
artifacts to run — FileFinder to find the drop, Prefetch/Amcache to confirm
execution, a live `Windows.System.PowerShell` collection to hash and unmask the
planted binary, and a Run-key check for persistence.

## Work it as a case

[`case-templates/sysmon/event_1_certutil_download_cradle.yaml`](case-templates/sysmon/event_1_certutil_download_cradle.yaml)
is a CoPilot case template (same schema as
[CoPilot-Case-Templates](https://github.com/socfortress/CoPilot-Case-Templates))
that walks an analyst through the whole investigation as ordered case tasks.

---

## Repo layout

```
simulate/
  run-chain.ps1     full ordered attack chain (downloads + runs stage2)
  stage2.ps1        benign second-stage payload (drop + persist)
  cleanup.ps1       remove everything the demo created
velociraptor/
  investigation.md  the artifacts + live PowerShell to investigate
case-templates/
  sysmon/event_1_certutil_download_cradle.yaml   CoPilot case playbook
```

---

## About SOCFortress

SOCFortress builds and supports open-source SOC/SIEM stacks. Learn more at
[socfortress.co](https://www.socfortress.co) · [CoPilot](https://github.com/socfortress/CoPilot)
· [YouTube](https://www.youtube.com/@taylorwalton_socfortress)
