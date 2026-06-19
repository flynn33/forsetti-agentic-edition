# Task Contract Template

Standard template for defining scope, authority, required outputs, documentation impact, release impact, and validation evidence for a governed task. Every required field must be completed before execution begins. Ambiguous or incomplete contracts must not be handed to a Builder.

The enforceable JSON template lives at `core/contracts/task-contract-template.json`. The machine-readable schema lives at `core/schemas/task-contract.schema.json`, mirrored at `schemas/task-contract.schema.json` for compatibility.

---

## Contract Identity

**Task ID:** FAE-TASK-YYYY-MM-DD-001
**Branch:** branch/name
**Created:** YYYY-MM-DD
**Repository:** Forsetti Agentic Edition

## Role Assignment

**Contract Authoring Role:** Architect
**Acting Role:** Builder
**Reviewer Role:** Validator
**Release Review Role:** Release Manager
**Documentation Review Role:** Documentation Manager

## Required Advisory Reviewers

- Add advisory reviewer names only when required by the task.

## Change Classification

**Change Class:** feature
**Approval Class:** standard
**Release Impact:** minor

## Forsetti Project Context

**Repository Mode:** consumer_app_repo
**Forsetti Edition:** apple
**Target Platform:** iOS
**Framework Version:** 0.1.3
**Edition Profile:** editions/apple/forsetti-apple-0.1.3.profile.json
**Manifest Schema Version:** 1.1
**Manifest Template Version:** 1.1
**Deployment Pattern:** single_app_module
**Module Type:** app
**Module ID:** com.example.module
**Capabilities Requested:** none
**Runtime Requirements Declared:** yes
**Uses Public API Only:** yes
**Touches Framework Internals:** no

If any value is unknown, the task is blocked until the Architect or human owner resolves it. Lower task instructions cannot override the selected edition profile, shared sealed-runtime invariants, manifest requirements, public API boundary, or module isolation rules.

## Governance Steward Authorization

**Required:** no
**Authority:**
**Evidence:**

## Objective

State the verifiable outcome of the task.

## Business Reason

Explain why this task is necessary.

## Downstream Impact Assessment

Identify affected documents, schemas, workflows, integrations, consumers, and migration needs. For breaking changes, include affected consumers and migration guidance expectations.

## Scope

### In Scope

- `path/to/authorized-file.md`

### Out of Scope

- `path/to/excluded-area/**`

## Required Outputs

- `path/to/required-output.md`

## Documentation Impact

**README update required:** no
**Wiki update required:** no
**Glossary update required:** no
**Changelog entry required:** yes
**Rationale:** Explain why documentation and changelog updates are or are not required.

## Validation Requirements

- Run the local validator in the applicable mode and capture evidence.
- Run `core/validator/forsetti_validate.ps1` with the applicable `-Mode`, `-ProjectContextPath`, `-EditionProfilePath`, `-ManifestPath`, and changed-file evidence when Forsetti app/module code is in scope.
- Confirm manifest schema/template, capabilities, runtime requirements, dependency direction, module isolation, public API use, and evidence against the selected profile.

## Evidence Requirements

- Files changed
- Forsetti project context
- Selected edition profile
- Manifest validation evidence when a manifest is in scope
- Capability and runtime requirement evidence when capability-using code is in scope
- Dependency and module-isolation evidence when app/module code is in scope
- Validation evidence
- Known issues
- Documentation status
- Release impact
- Scope compliance
## Constraints

- Stay within the authorized scope.

## Risks

- List known implementation or validation risks.

## Escalation Triggers

- Scope must expand beyond this contract.

## Definition of Done

- [ ] All in-scope changes are complete.
- [ ] Required outputs exist.
- [ ] Validation requirements are met with evidence.
- [ ] Documentation updates are complete or documented as not required.
- [ ] Changelog entry is complete when required.
- [ ] Completion summary is produced with evidence.
- [ ] No unresolved blocking issues remain.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues or limitations
- Documentation status
- Release impact
- Scope compliance
