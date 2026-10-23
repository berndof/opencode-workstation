---
name: architecture-design
description: >-
  Use this skill when the user asks for system architecture, solution design,
  technical trade-off analysis, RFC/spec drafting, or visual Mermaid architecture
  diagrams, or before implementing complex multi-component changes.
---

# Architecture & Solution Design (`architecture-design`)

Provide high-level technical guidance, evaluate trade-offs rigorously, design system architectures, and generate clear Mermaid diagrams before code is written.

## Core Directives

1. **Design Before Build:** When a request involves architectural choices or non-trivial trade-offs, produce the design, options analysis, and execution checklist first. Only proceed to implementation after the approach is aligned (unless explicitly asked to design and implement in one pass).
2. **Verified Evidence Only:** Every claim about existing architecture or code must cite `[filename](file:///abs/path#Lstart-Lend)`. Label anything not yet verified in code as `assumption` or `unverified`.
3. **Visual Mermaid Diagrams:** Include one clear Mermaid diagram when it clarifies structure or flow:
   - `flowchart TD` / `flowchart LR` or `graph TD` for architecture, dependencies, and decision trees.
   - `sequenceDiagram` for request/response flows and async interactions.
   - `erDiagram` for database schemas and data models.
   - `stateDiagram-v2` for lifecycle and state machines.
   - Always quote node labels containing special characters like parentheses or brackets (e.g., `api["API Gateway (Auth)"]`). Never use ASCII art.

## Substantive Architecture Response Standard

Follow this section order for architectural proposals and trade-off analyses (skip a section only when genuinely empty):

1. **RESUMO** — 1–2 sentences stating the core decision and your explicit recommendation upfront. Never bury the lead.
2. **CONTEXTO** — Max 5 bullets: verified codebase facts (`path:line`), hard constraints, explicit assumptions, and open unknowns.
3. **OPÇÕES** — Always compare 2–4 viable options (never present a single option disguised as a choice). Use a Markdown table when comparing 3+ options:

   | Opção | Abordagem | Prós | Contras | Risco | Custo / Complexidade |
   | :--- | :--- | :--- | :--- | :--- | :--- |

   Explicitly name the fallback option if the primary recommendation is rejected.
4. **ANÁLISE DE TRADE-OFFS** — Evaluate each option across:
   - **Reversibility:** Two-way door (easy to revert) vs. one-way door (high migration cost).
   - **Blast Radius:** What breaks if this component fails.
   - **Operational Cost:** Maintenance, observability, and infra overhead.
   - **What It Forecloses:** Future capabilities excluded by choosing this path (`se escolhermos A, excluímos B`).
5. **DIAGRAMA** — One Mermaid diagram illustrating the recommended architecture or sequence flow.
6. **RECOMENDAÇÃO** — The winning choice, why it wins in this specific context, what you explicitly recommend **NOT** doing (and why), and the **flip trigger** (*"se X acontecer no futuro, migre para a Opção Y"*).
7. **RISCOS & MITIGAÇÕES** — Top 3 failure modes and their concrete mitigations.
8. **PLANO DE EXECUÇÃO** — Ordered, atomic checklist where each step is independently verifiable and references real paths.
9. **PERGUNTAS** — If blocked on product or constraint decisions, invoke the `question` tool with `(Recommended)` on the default option.

## Formatting Discipline
- Prefer concrete numbers over vague adjectives (*"2 round-trips / +15ms p95"* instead of *"alguma latência"*).
- Keep code snippets under 15 lines and include them only when they express interfaces or contracts better than prose.
