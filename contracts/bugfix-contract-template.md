# Bugfix Contract Template

Template for correction of errors in existing governance content. Bugfix contracts must stay focused on the specific defect. No drive-by edits. No hidden refactors. No overclaiming fix status.

---

## Task ID

_Unique identifier for this bugfix._

**Value:** FAE-BUG-___

## Title

_Brief description of the bug being fixed._

**Value:**

## Date

**Value:** YYYY-MM-DD

## Initiating Request

_Reference to the issue, bug report, or observation that identified the defect._

**Value:**

## Acting Role

**Value:** builder

## Reviewer Role

**Value:** validator

## Change Class

**Value:** bugfix

## Approval Class

_Standard unless fix touches protected assets, then sensitive or governance-class._

**Allowed values:** standard | sensitive | governance-class

**Value:**

## Bug Description

_Clear description of what is wrong. Be specific. Reference the exact location, file, and content._

**Value:**

## Expected Behavior

_What the correct behavior or content should be._

**Value:**

## Actual Behavior

_What currently happens or exists._

**Value:**

## Root Cause

_Identified cause of the defect. If the root cause is unknown, state that explicitly._

**Value:**

## In Scope

_Files authorized for modification to fix this bug. Only files necessary for the fix._

-

## Out of Scope

_Explicitly excluded. No drive-by fixes. No opportunistic cleanup. No unrelated improvements._

-

## Fix Description

_What the fix will do. Must be specific enough to verify._

**Value:**

## Verification Method

_How the fix will be verified. Must produce observable evidence._

-

## Documentation Impact

- [ ] README update required
- [ ] Wiki update required
- [ ] No documentation impact

## Release Impact

**Value:** patch

## Definition of Done

- [ ] Bug is corrected
- [ ] Fix verified using stated verification method
- [ ] No drive-by edits or unrelated changes included
- [ ] Documentation updated if required
- [ ] Changelog entry added
- [ ] Completion summary produced with evidence

## Prohibited Actions

The following actions are explicitly forbidden under this contract:

- Fixing unrelated issues in the same files.
- Refactoring code or content beyond what is needed for the fix.
- Expanding scope to "also fix" adjacent problems.
- Claiming the fix is complete without running verification.
- Modifying files not listed in the In Scope section.
- Bundling cleanup, formatting, or style changes with the fix.
