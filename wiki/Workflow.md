# Workflow

> Canonical sources: [`AGENTS.md`](../AGENTS.md), [`CHANGE_CONTROL_POLICY.md`](../CHANGE_CONTROL_POLICY.md)

Summary of the task lifecycle and required workflow.

## Task Lifecycle

```
Contract → Scope → Execute → Validate → Release
```

1. **Contract**: Architect creates a task contract defining scope, authority, and expected outputs
2. **Scope**: Contract is reviewed and approved before execution begins
3. **Execute**: Builder implements changes within contract scope, updates documentation and changelog
4. **Validate**: Validator reviews compliance across all categories (scope, documentation, release, truthfulness)
5. **Release**: Release Manager confirms version classification, changelog integrity, and release readiness

## Key Rule

Agents do not help out. They operate under contract.

Work without a governing contract is unauthorized. Scope expansion without contract amendment is prohibited. Completion claims without evidence are blocking violations.

## Change Classes

Changes are classified as: feature, bugfix, refactor, docs, governance, release, metadata, or breaking-change. Each class has specific approval requirements and review roles.

## Approval Classes

Five approval levels exist: Standard, Sensitive, Governance-Class, Emergency, and Release-Critical. The required level depends on the change class and affected paths.

For full details, see [`CHANGE_CONTROL_POLICY.md`](../CHANGE_CONTROL_POLICY.md).
