# Release Contract Template

Template for release preparation work. Release contracts define the scope of a release, confirm readiness, and authorize the release. No release proceeds without a completed contract and confirmed readiness.

---

## Task ID

_Unique identifier for this release._

**Value:** FAE-REL-___

## Title

_Release title._

**Value:**

## Date

**Value:** YYYY-MM-DD

## Initiating Request

_Reference to the release preparation issue or milestone._

**Value:**

## Acting Role

**Value:** release_manager

## Reviewer Role

**Value:** validator

## Change Class

**Value:** release

## Approval Class

**Value:** release-critical

## Release Version

_Semantic version for this release._

**Value:**

## Release Type

**Allowed values:** patch | minor | major | governance-only

**Value:**

## Included Changes

_List all task references included in this release. Every included change must be listed._

| Task ID | Title | Change Class | Version Impact |
|---------|-------|--------------|----------------|
|         |       |              |                |
|         |       |              |                |
|         |       |              |                |

## Aggregate Version Impact

_The highest individual version impact among included changes. This determines the release version increment._

**Value:**

## Breaking Changes

_List any breaking changes included in this release. Each breaking change must have a migration note._

- [ ] No breaking changes included

_If breaking changes exist:_

| Change | Description | Migration Note |
|--------|-------------|----------------|
|        |             |                |

## Changelog Status

- [ ] All included changes have changelog entries
- [ ] Changelog entries are accurate and complete
- [ ] Breaking changes have migration notes

## Documentation Status

- [ ] README is current and accurate
- [ ] Wiki is synchronized with canonical sources
- [ ] No documentation drift detected

## Compliance Gate

- [ ] All included changes have been validated (pass)
- [ ] No unresolved blocking violations
- [ ] All required reviews completed

## Release Readiness

_All conditions must be satisfied before the release is authorized:_

- [ ] Version classification confirmed
- [ ] Changelog complete and accurate
- [ ] Documentation synchronized
- [ ] Compliance gates passed
- [ ] Release notes prepared
- [ ] No unresolved blocking violations

## Release Notes

_Summary of what is included in this release. Prepared from changelog entries. Must be accurate and complete._

**Value:**

## Definition of Done

- [ ] All readiness conditions satisfied
- [ ] Release notes finalized and reviewed
- [ ] Version tag applied
- [ ] Release authorized by Release Manager
- [ ] No conditions were waived without explicit Governance Steward approval
