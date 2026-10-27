# AGENTS.md (global)

## Acesso a hosts remotos — regra única

Todo trabalho em máquina remota passa pelo **agent-sandbox**:

- **Dev / escrita:** MCP `sbx_*` (`sbx_health`, `sbx_exec`, `sbx_make`, `sbx_wp`) → `127.0.0.1:47110`.
- **Prod / somente-leitura:** MCP `sbx_prod_*` → `127.0.0.1:47111`. O sistema de arquivos remoto é
  **EROFS**; qualquer escrita falha. Alvos mutantes (`hot`, `worktree`, `build`, `purge`, `wp eval`,
  `plugin activate`, `option update`) são negados pelo broker — não insista, não procure contorno.

**Nunca** invoque `ssh`, `scp`, `rsync`, `sshfs` ou `ocd` para trabalho de agente.
O `opencode-remote` foi desativado em 2026-10-20 (binários/atalhos/skill parqueados em
`~/.config/opencode/.backup_opencode_remote/`); não recrie esse fluxo.

## Gate de saúde (primeira ação da sessão)

1. `sbx_health` — se falhar, avise e pare o que dependa de dev.
2. Para qualquer tarefa de prod, antes de tudo: o túnel **precisa** estar de pé.
   Suba com `sbx-prod-on` (TTL padrão 120m, expira sozinho), confirme com `sbx-prod-on --status`
   e só então chame `sbx_prod_health`. Se o túnel estiver inativo, **não** tente `ssh` — peça ao
   usuário para rodar `sbx-prod-on`.

## Modelos (OpenCode Go & OmniRoute local)

- **Multi-host / Desktop (`opencode-go/*`, `opencode/*`):** funciona direto em qualquer host sem depender do OmniRoute.
- **Provider local `omni` (OmniRoute):** usado apenas na estação local (`https://omniroute.gruposcc.com.br/api/v1`, chave via `OMNIROUTE_API_KEY` de `~/.config/opencode/.secrets.env`); nos demais hosts pode ficar inativo.
- Default no `omni`: `omni/nemotron-lightning` (trocado de `omni/deepseek-chat` em 2026-10-23; deepseek caiu para fallback). Modelos abaixo só entram se passarem em teste com o prompt real do OpenCode (streaming + tool call + 2º turno): `groq/*` estoura **413 TPM 8000** em modo agente; `mistral`/`llm7` codestral devolvem argumentos como texto; `ms-web/muse-spark` volta vazio e leva até 110s; `nemotron-super-120b` e `cfp/kimi` estão sem credenciais.
- Confiabilidade medida no `omni` (2026-10-23): **nvidia (`nemotron-ultra`, `nemotron-lightning`) é confiável** — primeira opção para trabalho pesado. **groq (`gpt-oss-120b/20b`, `qwen3.8-27b`) é oficial, mas estoura "message too large" (TPM) em modo agente** — só para tarefas leves/triviais ou quando a nvidia cair. **Os demais (`deepseek-*`, `laguna-s`, `combo-*`, `qwen3.8-27b-exl3`) são fallback de emergência / coisas bobinhas.** Usuário não usa modelos `agy/*` via omni.
- Não reative o provider `agy` sem que o usuário peça explicitamente.

## Segredos

- Nunca leia nem exiba `**/.env`, `wp-config.php`, `~/.ssh/**`, `credentials.json`.
- Nunca imprima tokens; `opencode.json` já contém 2 segredos inline — não os replique em logs,
  arquivos novos ou respostas.
- Toda escrita em `/api/combos` do OmniRoute exige User-Agent de curl/browser (Cloudflare devolve
  `403 code 1010` para UA `Python-urllib`).

## Config local (opencode.json)

- O servidor re-normaliza `opencode.json` ao aplicar: permissions vira array de objetos
  `{action, resource, effect}` (last match wins) e `model` fica como última chave. Edite com
  anchors do formato atual (grep primeiro) — anchors do formato antigo (strings em `hard`) não
  casam mais. Valide com `python3 -m json.tool`.
