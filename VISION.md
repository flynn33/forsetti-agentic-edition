# Vision

**Authority**: Foundational reference document. Subordinate to `FORSETTI_CONSTITUTION.md`. Informational and directional — establishes mission, problem context, and strategic intent.

**Audience**: All contributors, adopters, and evaluators of Forsetti Agentic Edition.

---

## 1. Mission

Forsetti Agentic Edition exists to make agentic software delivery **disciplined, reviewable, and governable**.

It establishes a repository operating model in which coding agents and human contributors work within explicit boundaries, under explicit contracts, and toward outcomes that can be validated, reviewed, and traced.

The framework does not assume coding agents are unreliable. It assumes that **all contributors** — human and agent alike — produce better outcomes when operating under clear governance, defined authority, and required evidence. Governance is not punishment. It is infrastructure.

---

## 2. Problem Statement

Coding agents, when operating without governance, produce common failure patterns:

### 2.1 Uncontrolled Scope Expansion

Agents make changes beyond what was requested. A task to fix a bug becomes a refactor. A refactor becomes an architecture change. Each expansion introduces risk, increases review burden, and reduces traceability. Without explicit scope boundaries, agents optimize for perceived completeness rather than contractual precision.

### 2.2 Undocumented Changes

Modifications are made without updating documentation. README files describe capabilities that no longer exist. Wiki pages contradict canonical sources. Agent instructions reference workflows that have been replaced. The documentation surface decays silently because no governance rule requires synchronization.

### 2.3 Architectural Drift

Changes erode structural integrity because agents lack awareness of boundaries. Dependency directions reverse. Module isolation breaks. Internal APIs are consumed across boundaries. Each individual change appears reasonable; the cumulative effect is architectural degradation that is expensive to reverse.

### 2.4 False Completion Claims

Agents declare work "done" without running required validation. Tests are not executed. Linting is skipped. Guardrail scripts are ignored. The agent reports success based on its own assessment rather than evidence. Human reviewers who trust the completion claim inherit unvalidated risk.

### 2.5 Weak Validation Discipline

When validation is performed, it is often incomplete. Agents run a subset of tests, skip edge cases, or interpret test failures as acceptable. Without a compliance model that defines what "validated" means and what evidence is required, validation becomes performative rather than substantive.

### 2.6 Stale Documentation

READMEs and wikis fall out of sync with actual repository state. This is distinct from undocumented changes — stale documentation is the cumulative result of many small omissions. Over time, documentation becomes unreliable. Contributors stop reading it. New contributors receive incorrect orientation. The documentation surface becomes a liability rather than an asset.

### 2.7 Poor Release Traceability

Changes are merged without proper version classification or changelog entries. Releases are cut without clear records of what changed, why it changed, and what the impact is. Consumers cannot assess upgrade risk. Contributors cannot reconstruct the history of a decision. The release process becomes an administrative checkpoint rather than a traceability mechanism.

### 2.8 Frequency and Visibility

These failures are not unique to coding agents. Human contributors produce them too. But coding agents produce them at **higher frequency** and **lower visibility** than human contributors. Higher frequency because agents work faster and touch more files per session. Lower visibility because agents do not naturally flag their own governance gaps, and human reviewers may not catch failures that are distributed across many small changes.

This combination — high frequency, low visibility — makes governance essential rather than optional.

---

## 3. Vision for Disciplined Agentic Delivery

We envision repositories where coding agents behave as **disciplined engineering participants** rather than improvisational assistants.

In that model:

### 3.1 Contract-Driven Execution

Every task begins with a contract that defines scope, authority, and expected outputs. Agents do not improvise scope. They execute within boundaries. If a contract is insufficient, the agent requests clarification rather than expanding unilaterally.

### 3.2 Explicit Authority Boundaries

Every role has explicit authority boundaries that cannot be exceeded. An agent assigned the Builder role cannot approve its own work. An agent assigned the Validator role cannot modify production artifacts. Role separation prevents conflicts of interest and ensures independent verification.

### 3.3 Evidence-Based Compliance

Every meaningful change produces evidence of compliance. Tests were run — here are the results. Linting passed — here is the output. Documentation was updated — here is the diff. Compliance is demonstrated through evidence, not asserted through confidence.

### 3.4 Release Traceability

Every release is traceable through changelog and version classification. A consumer can read the changelog and understand what changed, why, and what impact to expect. A contributor can trace a release entry back to the PR, the contract, and the original task.

### 3.5 Documentation Integrity

Every documentation surface remains aligned with canonical sources. Wiki pages derive from authoritative documents. READMEs reflect actual repository state. Glossary terms match their usage in policy documents. Drift is detected, reported, and resolved — not tolerated.

### 3.6 Machine-Checkable Governance

Every governance rule is machine-checkable where practical. CI workflows enforce what can be automated. JSON policy manifests make rules parseable. Guardrail scripts validate structural compliance. Human judgment is reserved for decisions that require judgment, not for checks that can be automated.

---

## 4. Strategic Goal

Establish a governance framework that can be adopted by **any repository** using coding agents, providing:

1. **A constitutional foundation** for governance rules — a single highest-authority document that establishes principles, not just procedures.

2. **A role model** that separates planning, execution, validation, release, and documentation into distinct authorities with explicit boundaries.

3. **A contract system** that binds agent scope before execution begins, preventing uncontrolled expansion and ensuring traceability.

4. **A compliance model** that requires evidence, not confidence — where "done" means "validated and documented," not "I believe it works."

5. **A documentation model** that prevents drift through synchronization rules, canonical source authority, and required impact review.

6. **A release model** that ensures traceability through version classification, changelog requirements, and release readiness gates.

---

## 5. Desired Outcomes

### 5.1 Contracted Operation

Coding agents operate under contract, not improvisation. Every meaningful task has a defined scope, defined authority, and defined expected outputs. Agents that exceed scope are flagged. Agents that operate without contracts are non-compliant.

### 5.2 End-to-End Traceability

Every meaningful change is traceable from contract to release. A reviewer can follow the chain: task contract, PR, validation evidence, changelog entry, release version. No link in the chain is optional.

### 5.3 Machine-Enforceable Governance

Governance rules are machine-readable and enforceable via CI/CD where practical. JSON policy manifests, guardrail scripts, and automated checks reduce the burden on human reviewers and eliminate classes of violations that can be caught automatically.

### 5.4 Documentation Synchronization

Documentation stays synchronized with actual repository state. Canonical sources are authoritative. Derived surfaces are tracked. Drift is detected and resolved. Contributors can trust documentation because the governance model requires its maintenance.

### 5.5 Protected Governance Assets

Protected governance assets cannot be casually modified. The constitution, policies, and compliance model require explicit governance-class approval. CODEOWNERS enforcement prevents unreviewed changes to protected files. The governance layer is as protected as production code.

### 5.6 Visible Compliance

Compliance violations are detected and surfaced, not hidden. Agents that skip validation are flagged. PRs that omit required documentation are blocked. Drift is reported. The system makes non-compliance visible rather than allowing it to accumulate silently.

### 5.7 Trustworthy Agent Output

Human reviewers can trust agent-produced work because evidence is required. Trust is not based on the agent's self-assessment. Trust is based on validation results, documentation updates, compliance evidence, and changelog entries that the reviewer can independently verify.

---

## 6. Non-Goals

Forsetti Agentic Edition does not aim to:

### 6.1 Replace Human Judgment

The framework governs process, not decisions. Architectural decisions, design trade-offs, priority calls, and exception handling require human judgment. The framework ensures those decisions are documented and traceable, but it does not make them.

### 6.2 Automate All Review

Human review remains essential for semantic correctness, architectural fitness, and governance exceptions. The framework automates structural checks and compliance verification. It does not automate the judgment layer.

### 6.3 Define Application Behavior

Forsetti Agentic Edition governs repository operations, not application runtime. It does not define UI systems, business logic, data models, or runtime architecture. Those concerns belong to the application and its own architectural governance.

### 6.4 Enforce Language-Specific Standards

Coding style, language idioms, and implementation patterns belong to downstream repositories and their linting configurations. Forsetti Agentic Edition governs delivery discipline, not code aesthetics.

### 6.5 Serve as Project Management

The framework is not an issue tracker, sprint planner, or project management system. It governs how work is executed, validated, and released within a repository. Task prioritization, resource allocation, and roadmap planning are out of scope.

---

## 7. Long-Term Aspiration

Forsetti Agentic Edition aspires to become the **standard governance layer for governed agentic software delivery**.

That means a framework that any team can adopt — regardless of language, platform, or domain — to bring discipline, traceability, and accountability to repositories where coding agents participate in planning, building, validating, documenting, and releasing software.

The aspiration is not market dominance. It is **operational clarity**. Every team using coding agents faces the problems described in Section 2. Forsetti Agentic Edition provides a structured, adoptable, extensible answer to those problems.

The framework will evolve as agent capabilities evolve. As agents become more capable, the governance model adapts — not by removing governance, but by raising the bar for what "disciplined delivery" means in that context.

Governance scales with capability. More capable agents deserve more rigorous governance, not less.

---

## 8. Guiding Principles

These principles inform all framework decisions:

1. **Governance is infrastructure, not bureaucracy.** Rules exist to enable reliable delivery, not to slow it down.
2. **Evidence over confidence.** Demonstrated compliance is the only acceptable compliance.
3. **Contracts over improvisation.** Defined scope prevents uncontrolled expansion.
4. **Canonical sources over derived surfaces.** One authoritative source, many derived views.
5. **Visibility over convenience.** Making violations visible is more important than making workflows frictionless.
6. **Minimal viable governance.** Govern what matters. Do not govern what does not.
7. **Machine-checkable where practical.** Automate enforcement. Reserve human judgment for decisions that require judgment.
8. **Adaptable, not disposable.** The framework evolves with the ecosystem. It is not a static artifact.

---

## 9. Forsetti Framework Compliance Vision

FFAE also exists to make coding-agent work on Forsetti-based applications and modules comply with Forsetti Framework architecture. The product vision is governance-only enforcement: select the edition profile, validate the manifest, preserve module isolation, require declared capabilities, enforce public API boundaries, and require evidence before completion claims.

FFAE must not become the runtime that it governs. Apple and Windows framework repositories remain source-truth references for profiles and invariants; FFAE remains the contract, policy, validation, and documentation layer.

*This document is a canonical source. It establishes the mission, problem context, and strategic direction for Forsetti Agentic Edition.*
