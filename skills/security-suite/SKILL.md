---
name: security-suite
description: >-
  Use this skill when performing defensive code audits (OWASP Top 10, CWE
  compliance, secret hygiene, auth/crypto/network/input validation), verifying
  issue reachability via read-only traces, or applying least-privilege hardening patches.
---

# Defensive AppSec Audit, Verification & Hardening (`security-suite`)

This skill unifies the 3-stage defensive security workflow (**SecAudit -> SecVerify -> SecFix** — agents `sec-audit` → `sec-pentest` → `sec-fix`) for static code compliance (SAST), safe reachability verification, and least-privilege remediation.

---

## Stage 1: Static Compliance & Code Audit (`SecAudit`)

Perform when reviewing security-sensitive changes (authentication, cryptography, network/CORS, file uploads, SQL/ORM queries, command execution, serialization, or IAM/infra configs).

### Scope & Rules
- **Compliance Frameworks:** OWASP Top 10, CWE mapping, secret/credential hygiene, dependency health, input/output sanitization (SSRF/XSS/SQLi/IDOR/CSRF prevention), CORS policy, security headers/CSP/TLS configuration, and cryptographic strength.
- **Secrets Hygiene:** NEVER print full secrets, tokens, or private keys in chat or artifacts. Reference them strictly as:
  `file:line + credential_type + redacted prefix (first 4 chars...)`.
- **Evidence Discipline:** Every finding must cite exact `[filename](file:///abs/path#Lstart-Lend)` evidence. Never speculate without code evidence; mark uncertain patterns with `CONFIDENCE: low`.
- **Optional Read-Only Subagent Isolation:** For broad code audits, delegate to the read-only `sec-audit` agent (or `reviewer`) so static inspection runs in an isolated context.

### Audit Finding Format
Order findings from `Critical` to `Info`:
```text
FINDING: <concise title>
SEVERITY: Critical | High | Medium | Low | Info
CWE/OWASP: <CWE-XXX / A0X:2021-Name>
EVIDENCE: <path:line + minimal code snippet>
RISK_IMPACT: <one-line technical risk description>
CONFIDENCE: high | medium | low
```

---

## Stage 2: Reachability & Boundary Verification (`SecVerify`)

Use when a static finding or bug report requires confirming whether the code path is actually reachable and unguarded in practice before applying a fix (eliminating false positives).

### Operational Guardrails
1. **Strictly Non-Disruptive:** Read-only verification only. Never delete data, never run load/stress tests, and never mutate application state.
2. **Data Privacy:** Never send secrets, tokens, or PII outside the local workspace. Redact sensitive values in all reports.
3. **Authorized Workspace Scope:** Only inspect local code, configurations, and endpoints belonging to the active project.
4. **Diagnostic Traces:** Demonstrate reachability using call-graph tracing, HTTP header/response inspection, unit test assertions, or dry-run configuration checks.

### Verification Report Format
```markdown
## [SEVERITY] Title (CWE-XXX / OWASP)
- **Location:** `file:line` or `METHOD /route`
- **Call Path / Trace:** Numbered steps showing how input reaches the sink without validation
- **Evidence:** Code trace, headers, or linter/scanner output
- **Risk Summary:** Technical impact if left unpatched
- **Remediation Hint:** Specific hardening guidance for Stage 3 (`SecFix`)
- **Confidence:** high | medium | low
```

---

## Stage 3: Least-Privilege Hardening (`SecFix`)

Apply minimal, surgical patches to remediate confirmed findings without expanding scope or introducing regressions.

### Secure-Coding Guardrails
1. **Least Privilege & Minimal Diff:** Smallest code change that resolves the root cause. Do not mix feature work or unrelated refactors into a hardening patch.
2. **Input/Output Defense:** Validate inputs against strict allowlists, encode outputs for their target context, and parameterize all SQL/NoSQL/OS commands (zero string concatenation).
3. **Disallowed Anti-Patterns (Never Introduce):**
   - `eval()`, `new Function()`, unvalidated `child_process.exec` / `shell=True`
   - `innerHTML` or `dangerouslySetInnerHTML` without DOMPurify/sanitization
   - Hardcoded secrets/keys (move to environment variables or secret manager)
   - `Access-Control-Allow-Origin: *` on authenticated routes
   - `verify=False` / `rejectUnauthorized: false` in TLS clients
   - MD5/SHA1 for password hashing, or JWT `alg: "none"` / missing expiration
4. **Dependencies:** Prefer minimal patched semver bumps and verify lockfile integrity; never run `npm install --force` without explicit user approval.

### Post-Fix Verification
1. Re-grep the codebase for the anti-pattern to ensure no sibling occurrences were missed.
2. Run the project's test suite, linter, and typechecker to confirm zero regressions.
