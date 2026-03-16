# Governance Change Contract Template

Template for changes to constitutional, policy, compliance, or governance-related content. Governance changes require elevated authority and must not be bundled with non-governance work. Every governance change is reviewed by both the Validator and the Governance Steward.

---

## Task ID

_Unique identifier for this governance change._

**Value:** FAE-GOV-___

## Title

_Brief description of the governance change._

**Value:**

## Date

**Value:** YYYY-MM-DD

## Initiating Request

_Reference to the governance change issue or proposal._

**Value:**

## Acting Role

_Architect for planning, Builder for execution._

**Value:**

## Reviewer Role

**Value:** validator + governance steward

## Change Class

**Value:** governance

## Approval Class

**Value:** governance-class

## Current Rule

_The current governance rule, policy, or content being changed. Quote or reference the specific text. Do not paraphrase._

**Value:**

## Proposed Rule

_The proposed new governance rule, policy, or content. Must be complete and unambiguous._

**Value:**

## Rationale

_Why this change is necessary. What problem does the current rule create or fail to address? What evidence supports the need for change?_

**Value:**

## Affected Policies

_List all policy documents, standards, manifests, and schemas affected by this change. Every affected document must be listed._

-

## Downstream Impact

_How this change affects existing consumers, workflows, contracts, or compliance. If no downstream impact, state that explicitly with justification._

**Value:**

## Backward Compatibility

_Is this change backward-compatible? If not, what breaks and what migration is required?_

**Value:**

## Approval Authority

_Who must approve this change. Governance Steward approval is mandatory for governance-class changes._

**Value:**

## In Scope

_Files authorized for modification. Only governance-related files._

-

## Out of Scope

_Non-governance files and concerns explicitly excluded. Governance changes must not be bundled with implementation work._

-

## Documentation Impact

- [ ] README update required
- [ ] Wiki update required
- [ ] Glossary update required
- [ ] Constitutional amendment required

## Release Impact

**Allowed values:** governance-only | major (if breaking)

**Value:**

## Rollback Plan

_How this change can be reversed if it causes problems. Governance changes without a rollback plan require explicit justification._

**Value:**

## Definition of Done

- [ ] Governance change implemented as proposed
- [ ] All affected policies updated consistently
- [ ] Downstream impact documented
- [ ] Wiki synchronized with canonical sources
- [ ] Glossary updated if new terms introduced
- [ ] Changelog entry added with governance classification
- [ ] Validator approval obtained
- [ ] Governance Steward approval obtained
- [ ] No non-governance changes bundled
- [ ] Rollback plan documented or explicit justification provided
