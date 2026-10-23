---
name: quality-and-debug
description: >-
  Use this skill when reproducing and fixing bugs or stacktraces, performing
  read-only code reviews (quality gate on git diffs), writing or running unit
  and integration tests, or synchronizing technical documentation with code.
---

# Debugging, Testing, Code Review & Docs Sync (`quality-and-debug`)

Standardized workflows for root-cause debugging, test engineering, read-only diff review, and documentation maintenance.

---

## 1. Surgical Debugging (`Debugger`)

Follow this strict sequence when diagnosing failures, regressions, or stacktraces:

1. **Reproduce:** Identify the exact failing command, test, or request and capture the baseline error output (`BEFORE`).
2. **Isolate Root Cause:** Trace the execution path to the exact `[filename](file:///abs/path#Lstart-Lend)` responsible for the bug. Fix the root cause, not the symptom.
3. **Minimal Patch:** Touch the fewest lines and files possible. Do not bundle refactors or formatting cleanups into a bugfix.
4. **Verify (`AFTER`):** Re-run the exact reproduction command plus related unit/lint checks to prove the fix works.

### Bugfix Summary Block
- **Root Cause:** `<one-line explanation + file:line>`
- **Fix Applied:** `<minimal description of change>`
- **Verification:** `<command executed + BEFORE -> AFTER result>`

---

## 2. Read-Only Code Review (`Reviewer Quality Gate`)

When asked to review a branch, PR, or uncommitted `git diff`:

1. **Read-Only Posture:** Inspect changes via `git diff`, file views, and grep. Do not mutate files during a review unless asked to apply fixes afterward.
2. **Review Checklist:**
   - **Correctness & Edge Cases:** Null/undefined handling, race conditions, off-by-one errors, resource leaks, error propagation.
   - **Architecture & SOLID:** Single responsibility, coupling, adherence to existing repository conventions.
   - **Security & Secrets:** Injection vectors, missing auth/validation, accidental secret or debug logging leaks.
   - **Performance:** N+1 queries, unnecessary allocations, blocking I/O in hot paths.
3. **Structured Verdict:**
   - **Verdict:** `APPROVE` or `REQUEST_CHANGES`
   - **Findings:** Numbered list ordered by severity (`Critical`, `High`, `Medium`, `Low`, `Nit`) with clickable `[file:line](file:///abs/path#Lline)` links and concise fix suggestions.

---

## 3. Test Engineering (`Tester`)

When generating or updating unit/integration tests:

1. **Scope Separation:** Place tests according to the repository's convention (`tests/`, `__tests__/`, `*.test.*`, `*_test.*`). When asked *only* to write tests, never silently modify production `src/` logic to make a failing test pass—report the production bug instead.
2. **Framework Detection:** Inspect `package.json`, `pyproject.toml`, `go.mod`, or `Cargo.toml` to use the exact runner configured in the repo (`vitest`, `jest`, `pytest`, `go test`, etc.).
3. **Execution Report:** Always run the newly created/updated tests and report the exact command, pass/fail count, and failure excerpts if any.

---

## 4. Documentation Sync (`Documenter`)

When writing or updating `README.md`, `CHANGELOG.md`, runbooks, or docstrings:

1. **Verify Against Code:** Never document flags, env vars, endpoints, or function signatures from memory. Read/grep the current source code first so every example is accurate.
2. **Concise & Actionable:** Prefer copy-pasteable commands, tables for configuration variables, and real file links over long walls of text.
