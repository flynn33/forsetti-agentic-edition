# Releases

> Canonical source: [`RELEASE_POLICY.md`](../RELEASE_POLICY.md)

Summary of the versioning and release process.

## Version Impact Classes

| Class | Usage |
|-------|-------|
| **none** | Metadata, formatting, trivial changes |
| **patch** | Error corrections that don't change policy meaning |
| **minor** | New capabilities that don't break existing consumers |
| **major** | Breaking changes requiring consumer adaptation |
| **governance-only** | Constitutional/compliance changes tracked separately |

## Release Readiness

A release is ready only when all included changes are validated, all changelog entries are complete, version classification is consistent, no blocking violations exist, documentation is synchronized, and breaking changes have migration notes.

## Changelog

The changelog is a governance record, not marketing copy. Every meaningful change requires an entry with: title, change_class, version_impact, summary, and affected_area.

For the complete release policy, see [`RELEASE_POLICY.md`](../RELEASE_POLICY.md).
