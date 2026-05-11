# AI Assistance Accountability Policy

**Governing Authority**: COMPLIANCE_POLICY.md, subordinate to FORSETTI_CONSTITUTION.md
**Policy Level**: Compliance support policy
**Approval Class**: Governance-Class

---

## Purpose

This policy defines accountability requirements for AI-assisted work without permitting attribution credit to any tool, model, vendor, automation, or agent.

Accountability belongs to the accountable human owner and the governed role acting under an approved task contract. Assistance does not create authorship, contributor status, approval authority, validation authority, or release authority.

---

## Non-Attribution Rule

AI attribution of any kind is prohibited in:

- source files
- generated code comments
- commit messages
- changelog entries
- release notes
- README notices, footers, and headers
- contributor lists
- authorship metadata
- documentation prose that credits an AI system

The prohibited attribution rule applies to repository content, generated artifacts, release materials, pull request metadata, commit metadata, and any other governed delivery surface.

---

## Accountability Record

Governed work may record accountability evidence only for:

- accountable human owner
- acting governed role
- contract ID or remediation phase ID
- review evidence
- validation evidence
- approval evidence when required by path, role, or approval-class policy

The accountability record must never credit, thank, cite, list, or attribute work to any tool, model, vendor, automation, or agent.

---

## Contract Requirements

Task contracts for AI-assisted work must identify the accountable human owner and the governed role responsible for the work. They may reference a remediation phase or task contract ID for traceability.

The contract must not assign authorship, contributor credit, review authority, validation authority, approval authority, or release authority to assistance.

---

## Evidence Requirements

Completion evidence must show:

- the accountable human owner
- the acting governed role
- the governing contract or remediation phase
- the reviewer role and review evidence
- validation evidence
- approval evidence when required
- confirmation that prohibited attribution was not added

Validation evidence must distinguish accountability records from attribution credit. Evidence can prove that assistance was governed, reviewed, and approved; it must not credit assistance as an author, contributor, source, reviewer, validator, releaser, or maintainer.

---

## Rejection Conditions

A change must be rejected or marked for changes if it:

1. Adds attribution credit to any prohibited surface.
2. Adds authorship or contributor metadata for a tool, model, vendor, automation, or agent.
3. Uses changelog, release note, README, footer, header, or documentation prose to credit assistance.
4. Omits the accountable human owner, governed role, contract ID, review evidence, validation evidence, or required approval evidence.
5. Presents assistance as a substitute for required human or governed-role accountability.

---

## Relationship to FAE-C012

FAE-C012 is the compliance rule for AI assistance accountability and non-attribution. The canonical machine-readable support policy is `core/policies/ai-assistance-disclosure.json`.

---

*This document is a canonical source. Derived wiki summary: `wiki/Compliance.md`.*
