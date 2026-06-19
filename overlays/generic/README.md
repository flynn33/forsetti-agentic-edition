# Generic Forsetti Governance Overlay

This overlay applies when a task is Forsetti-related but no platform-specific implementation path is selected yet.

## Required Context

Before execution, the Architect must select:

- repository mode;
- Forsetti edition;
- target platform;
- framework version;
- edition profile;
- manifest schema/template version;
- deployment pattern;
- module type;
- requested capabilities;
- runtime requirements status;
- public API boundary status;
- framework-internals status.

Missing or ambiguous context blocks Builder execution.

## Governance Boundary

FFAE may validate contracts, profiles, manifests, capabilities, runtime requirements, dependency direction, module isolation, public API use, and evidence. It must not implement runtime behavior or platform services.

## Evidence

Completion evidence must map to the selected edition profile and include changed files, validation commands, manifest checks where applicable, capability/runtime evidence where applicable, dependency/module-isolation evidence where applicable, and no-attribution confirmation.
