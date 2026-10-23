---
name: infra-cloud-ops
description: >-
  Use this skill when working with Dockerfiles, Docker Compose, systemd services,
  Nginx/Caddy/Traefik reverse proxies, Cloudflare (DNS, WAF, Workers, KV), Zabbix
  monitoring via MCP, or remote hosts (portal-dev/portal-prod via agent-sandbox).
---

# Infrastructure, Cloud, Monitoring & Remote Ops (`infra-cloud-ops`)

Guidelines and safety guardrails for containers, reverse proxies, Cloudflare edge services, Zabbix monitoring, and SSH remote host management.

---

## 1. Containers, Systemd & Reverse Proxies (`Infra`)

### Best Practices by Default
- **Dockerfiles:** Use multi-stage builds, minimal base images (`alpine`, `slim`, `distroless`), pinned image versions (avoid unpinned `:latest` in production), and non-root execution (`USER app` / `USER 1000:1000`).
- **Docker Compose:** Define explicit `healthcheck` blocks, `depends_on: condition: service_healthy`, explicit network segmentation, `restart: unless-stopped`, and sensible resource limits.
- **Configuration Hygiene:** Separate config from code using `.env.example` templates. Never bake secrets or private keys into container images or layers.
- **Verification:** Always validate syntax after edits using `docker compose config`, `nginx -t`, `caddy validate`, or `systemd-analyze verify`.

### Destructive Action Guards
- **NEVER** execute `docker volume rm`, `docker system prune -a --volumes`, `docker compose down -v`, or `rm -rf /var/lib/...` without explicit user confirmation and backup verification.
- Respect Linux UID/GID permissions on bind-mounted host volumes.

---

## 2. Zabbix Monitoring (`zabbix` MCP)

When inspecting or managing monitoring via the `zabbix` MCP server (configured in `~/.config/opencode/opencode.json` → `mcp.servers.zabbix`; specialist agent: `zabbix`):

1. **Read-Only by Default:** Query hosts, active problems (`problem_active_get`, `problem_get`), triggers, items, history, and capacity forecasts without modifying state.
2. **Targeted Queries:** Always apply host/group filters and `limit` parameters. Do not dump full Zabbix inventories into the context window unless requested.
3. **Mutation Gate (`action_prepare` / `action_confirm`):** Never create, update, or delete hosts, triggers, items, or maintenance windows without:
   - Explaining the exact impact to the user first and getting confirmation.
   - Using the Zabbix MCP `action_prepare` and `action_confirm` workflow when applicable.
4. **Concise Reporting:** Summarize findings in structured tables (Host, Severity, Problem/Trigger, Item Value, ID) instead of dumping raw JSON payloads.

---

## 3. Cloudflare Edge (`cloudflare` & `cloudflare-docs` MCPs)

When managing DNS, WAF rules, Workers, or KV via the `cloudflare` MCP server:

1. **Docs First:** When configuring Workers, Wrangler, or WAF expressions, query `cloudflare-docs` (`search_cloudflare_documentation`) to verify current syntax and limits.
2. **Change Safety:** Before mutating DNS records, SSL/TLS modes, or WAF firewall rules, display the current state vs. proposed state so rollback is trivial.
3. **Least Disruption:** Preferstaging/preview environments or dry-run validation before applying production WAF/routing rules.

---

## 4. Remote Hosts (portal-dev / portal-prod)

NUNCA use `ssh`, `scp`, `rsync`, `sshfs` ou `ocd` para trabalho de agente — o acesso remoto passa
exclusivamente pelo agent-sandbox (MCP `sbx_*` / `sbx_prod_*`, túneis `127.0.0.1:47110` /
`127.0.0.1:47111`). Carregue a skill `agent-sandbox` para o fluxo completo: dev com escrita,
produção somente-leitura (EROFS), edição de código sempre local → commit → sync.
