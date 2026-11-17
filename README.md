# Window Debloat Agent

A Windows debloating tool for AI agents and their owners. Use it to inventory installed software, plan the removal of unwanted Windows AI tools such as Microsoft Copilot, review Recall snapshots, and reduce optional Windows data collection (telemetry). The PowerShell collector is read-only. The agent delivers an owner-reviewed plan.

## Give this prompt to your agent

> Use writtenonwater99/Window-Debloat-Agent to review my Windows PC. Read AGENTS.md, run the local inventory, identify unwanted apps and Windows AI features, and explain which privacy settings control optional data collection. Ask me about uncertain items and show the scope and consequences before I decide.

## Repository contents

| File | What an agent uses it for |
| --- | --- |
| [AGENTS.md](AGENTS.md) | Start here for the workflow, owner questions and approval rules. |
| [Review-Windows.ps1](Review-Windows.ps1) | Collect installed apps, Windows build, optional features, startup entries and drive capacity as JSON. |
| [AI-AND-PRIVACY.md](AI-AND-PRIVACY.md) | Review Copilot removal, Recall capture and deletion, and optional diagnostic data. |
| [RESEARCH.md](RESEARCH.md) | Compare debloating approaches and understand inventory gaps. |
| [Test-Review.ps1](Test-Review.ps1) | Check the report format and partial-failure handling locally. |

## Run the inventory

Use native 64-bit Windows PowerShell 5.1 on a 64-bit PC. From this directory run:

    .\Review-Windows.ps1

Start as your usual user. The script prints local JSON. Each section reports its own collection status. Provisioned packages and optional features can require elevation. Review what was accessible first. Keep real inventories out of public issues because installed software and error messages can identify the machine or account.

## Coverage

This preview inventories desktop uninstall registrations, current-user Store packages, provisioned packages for new users, optional features and common startup entries. Portable apps, other users' installations, tasks, services, drivers and some startup or management mechanisms fall outside its coverage. Domain membership alone cannot establish whether a device is unmanaged.

| Environment | Review | Automated changes |
| --- | --- | --- |
| Local Windows PowerShell environment | Smoke test only | None |
| Windows 10, Windows 11, Windows Server, ARM64 | Build-specific validation pending | None |

## Example review

If Xbox Game Bar appears, ask whether the owner uses game capture or its overlay. If a vendor hotkey utility appears, identify its hardware role before discussing removal. If a shared runtime appears, keep it. These are illustrative examples. Version-specific removal and recovery procedures require validation before inclusion.

## Reading the report

Schema 2 includes the system drive capacity, a native architecture hint, desktop registration key names, full current-user package names, and native-view Run entry names. Sections marked incomplete can contain partial observations. Startup registration alone does not measure sign-in delay. Domain membership is only one management signal.

If local policy allows a process-scoped launch, the following runs the locally reviewed script with RemoteSigned for that process. Organization policy still applies.

    powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\Review-Windows.ps1

See the [tool survey and audit](RESEARCH.md) for the evidence behind the review workflow.
