# Task Contract Template

Standard template for defining scope, authority, and expected outputs for a task. Every field must be completed before execution begins. Ambiguous or incomplete contracts must not be handed to a Builder.

---

## Task ID

_Unique identifier for this task (e.g., FAE-TASK-001)._

**Value:**

## Title

_Brief descriptive title of the task._

**Value:**

## Date

_Date the contract was created._

**Value:** YYYY-MM-DD

## Initiating Request

_Reference to the issue, PR, or request that initiated this task._

**Value:**

## Acting Role

_The role executing this task._

**Allowed values:** architect | builder | validator | release_manager | documentation_manager

**Value:**

## Reviewer Role

_The role responsible for reviewing this task._

**Allowed values:** validator | release_manager | documentation_manager | architect

**Value:**

## Change Class

_Classification of the change._

**Allowed values:** feature | bugfix | refactor | docs | governance | release | metadata | breaking-change

**Value:**

## Approval Class

_Required approval level._

**Allowed values:** standard | sensitive | governance-class | emergency | release-critical

**Value:**

## Objective

_Clear statement of what this task will accomplish. Must be specific enough that completion can be verified._

**Value:**

## Business Reason

_Why this task is needed. The problem it solves or the value it provides._

**Value:**

## In Scope

_Explicit list of files, directories, or areas authorized for modification. Every authorized target must be listed. If it is not listed, it is not authorized._

-
-

## Out of Scope

_Explicit list of areas NOT authorized for modification. Ambiguity about boundaries is resolved by this section: if something could be in scope but is listed here, it is out of scope._

-
-

## Required Outputs

_List of deliverables expected upon completion. Each output must be verifiable._

-
-

## Documentation Impact

_Check all that apply:_

- [ ] README update required
- [ ] Wiki update required
- [ ] Glossary update required
- [ ] No documentation impact

## Release Impact

_Version impact classification._

**Allowed values:** none | patch | minor | major | governance-only

**Value:**

## Validation Requirements

_Specific validation steps required before completion can be claimed. Each step must produce verifiable evidence._

-
-

## Risks and Constraints

_Known risks, dependencies, or constraints that could affect execution._

-
-

## Escalation Triggers

_Conditions that require escalation rather than continued execution._

-
-

## Definition of Done

_Specific conditions that must all be true for this task to be complete:_

- [ ] All in-scope changes implemented
- [ ] Documentation updated as required
- [ ] Changelog entry added (if meaningful change)
- [ ] Validation requirements met with evidence
- [ ] Completion summary produced with evidence
- [ ] No unresolved blocking issues

## Completion Summary Requirements

_The completion summary submitted by the Builder must include all of the following:_

- Files changed (complete list)
- Evidence of validation (specific results, not assertions)
- Known issues or limitations (if any, or explicit "none")
- Documentation status (updated / not required / needs-sync)
- Release impact confirmed
