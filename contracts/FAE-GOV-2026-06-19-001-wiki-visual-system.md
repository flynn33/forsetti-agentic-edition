# Task Contract: Wiki Visual System Refresh

## Contract Identity

**Task ID:** FAE-GOV-2026-06-19-001
**Branch:** docs/wiki-visual-alignment
**Created:** 2026-06-19
**Repository:** Forsetti Agentic Edition

## Role Assignment

**Contract Authoring Role:** Architect
**Acting Role:** Builder
**Reviewer Role:** Validator
**Release Review Role:** Release Manager
**Documentation Review Role:** Documentation Manager

## Required Advisory Reviewers

- documentation-manager
- governance-steward

## Change Classification

**Change Class:** docs
**Approval Class:** governance-class
**Release Impact:** patch

## Forsetti Project Context

**Repository Mode:** governance_repo
**Forsetti Edition:** apple
**Target Platform:** macOS
**Framework Version:** 0.1.3
**Edition Profile:** editions/apple/forsetti-apple-0.1.3.profile.json
**Manifest Schema Version:** 1.1
**Manifest Template Version:** 1.1
**Deployment Pattern:** framework_governance
**Module Type:** not_applicable
**Module ID:** null
**Capabilities Requested:** none
**Runtime Requirements Declared:** false
**Uses Public API Only:** true
**Touches Framework Internals:** no

## Governance Steward Authorization

**Required:** yes
**Authority:** Flynn33, repository owner and Governance Steward
**Evidence:** On 2026-06-19, Flynn33 requested updating and aligning the live Forsetti Agentic Edition wiki pages with the highest achievable GitHub Wiki visual quality.

## Objective

Refresh the repository wiki mirror and live GitHub Wiki with a curated visual documentation system that improves navigation, architecture diagrams, logic-flow diagrams, compliance maps, release diagrams, and documentation-sync clarity.

## Business Reason

The live wiki is the public orientation surface for the governance framework. It must remain aligned with repository documentation while presenting the framework at a higher visual and navigational quality than raw canonical-document mirrors.

## Downstream Impact Assessment

The repository wiki mirror and live wiki become curated derived documentation surfaces. The GitHub Actions wiki sync adapter changes from generating raw wiki pages from canonical documents to publishing the reviewed `wiki/*.md` mirror directly. This preserves curated visual content while keeping canonical repository files authoritative.

## Scope

### In Scope

- `contracts/FAE-GOV-2026-06-19-001-wiki-visual-system.md`
- `wiki/*.md`
- `changelog/CHANGELOG.md`
- `adapters/github-actions/workflows/sync-wiki-pages.ps1`
- Live GitHub Wiki repository pages

### Out of Scope

- Runtime behavior
- Validator rule behavior
- Version number changes
- Dependency changes
- Policy meaning changes outside the wiki publication adapter
- Repository files outside the listed scope

## Required Outputs

- Refreshed repository wiki mirror pages
- Refreshed live GitHub Wiki pages
- Updated wiki synchronization adapter
- Changelog entry for the meaningful documentation change
- Validation evidence for wiki links, Mermaid fences, JSON parsing, repository tests, and diff hygiene

## Documentation Impact

**README update required:** no
**Wiki update required:** yes
**Glossary update required:** yes
**Changelog entry required:** yes
**Rationale:** The task directly updates the wiki visual system, glossary-style terminology page, and publication adapter. The changelog must record the meaningful documentation and adapter change.

## Validation Requirements

- Verify repository wiki Markdown code fences and Mermaid fence balance.
- Verify repository wiki internal links resolve to available wiki pages.
- Verify live wiki Markdown code fences and Mermaid fence balance.
- Verify live wiki internal links resolve to available wiki pages.
- Parse repository JSON files.
- Run remediation acceptance tests.
- Run shell syntax validation for `scripts/validate-repo.sh`.
- Run diff whitespace validation.
- Attempt the repository validation wrapper and report if a PowerShell host is unavailable.

## Evidence Requirements

- Files changed
- Repository wiki and live wiki synchronization evidence
- Validation commands and results
- Known limitations
- Documentation status
- Release impact
- Scope compliance

## Constraints

- Stay within this contract scope unless amended first.
- Preserve canonical repository files as the source of truth.
- Do not add dependency changes.
- Do not change version numbers.
- Do not add attribution credit.

## Risks

- GitHub Wiki does not support custom CSS or JavaScript, so advanced visual quality must be achieved with supported Markdown, Mermaid, tables, badges, navigation, and progressive disclosure.
- Local PowerShell validation may be unavailable if no PowerShell host is installed on PATH.

## Escalation Triggers

- The wiki refresh requires policy meaning changes outside this contract.
- The publication adapter cannot preserve the curated mirror without broader workflow changes.
- Hosted checks fail and cannot be reproduced or resolved within this scope.

## Definition of Done

- [ ] Repository wiki mirror pages are refreshed.
- [ ] Live GitHub Wiki pages are published.
- [ ] Wiki synchronization adapter publishes curated `wiki/*.md` content.
- [ ] Changelog entry is complete.
- [ ] Required local validation evidence is captured.
- [ ] Branch is pushed and pull request is created for repository review.
- [ ] Hosted pull request checks pass or failures are reported with evidence.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues or limitations
- Documentation status
- Release impact
- Scope compliance
