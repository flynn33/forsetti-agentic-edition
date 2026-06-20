<!-- FORSETTI-GOVERNANCE:BEGIN -->
## Forsetti Governance

This repository is governed by the pinned Forsetti Agentic Edition product described in:

```text
.forsetti/product.lock.json
.forsetti/policy.lock.json
.forsetti/profile.lock.json
.forsetti/instructions/GOVERNANCE.md
```

Before meaningful edits:

1. run the platform-native `forsetti-governance doctor`;
2. run `forsetti-governance task status`;
3. when no authorized active task exists, run `forsetti-governance task begin --contract <path>` before editing;
4. remain within task scope;
5. run `task check` during implementation;
6. use `task submit`, independent `task validate`, and `task complete` before claiming completion.

Direct module coupling, direct module data sharing, undeclared capability use, private framework use, invalid manifests, and missing evidence are non-compliant.

Local instructions may narrow this section but may not weaken the pinned profile or shared Forsetti invariants.
<!-- FORSETTI-GOVERNANCE:END -->
