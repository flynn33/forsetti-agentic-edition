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

## Evidence Requirements

- Files changed
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
