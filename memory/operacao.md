---
description: >-
  Diretrizes operacionais globais do usuário (portadas do AGENTS.md do agy): bloqueio de produção, fluxo dev, git
  safety, hierarquia da verdade, protocolo de perguntas e idioma.
label: operacao
limit: 5000
read_only: false
---
## Bloqueio Absoluto de Produção (regra fixa do usuário)
- NUNCA acessar, conectar, executar comandos ou fazer deploy em PRODUÇÃO (portal-prod). Produção é somente-leitura via `sbx_prod_*` (EROFS); o túnel precisa estar de pé (`sbx-prod-on`).
- Qualquer necessidade relativa a produção deve ser guiada passo a passo para o próprio USUÁRIO executar manualmente. O agente atua apenas em desenvolvimento (dev/local).

## Fluxo Mandatório Dev (proibida edição direta no remoto)
1. Edição 100% local no repositório.
2. Commit semântico no Git local.
3. Sync no dev via Git (`git push` local + pull no portal-dev via sbx).
4. Tema hot rodando no dev (`make hot` / symlink `scc10-dev-bernardo`).
- `sbx` no dev serve apenas para diagnóstico, testes (`sbx make test`), profiling, WP-CLI e build — JAMAIS para editar arquivos do tema no servidor.

## Git Safety (dirty tree)
- Inspecionar `git status` antes de edições amplas; se houver sujeira alheia (outra sessão/usuário), tocar somente nos arquivos-alvo.
- NUNCA comandos destrutivos em lote sem pedido explícito do usuário: `git reset --hard`, `git checkout .`, `git restore .`, `git clean -fd`, `git push --force`, `git add .`/`git add -A` com sujeira alheia; `rm -rf` em paths amplos; `docker system prune -a --volumes`; `docker volume rm`.
- Se um arquivo-alvo foi modificado externamente durante a execução: ler o diff e integrar aditivamente; se irreconciliável, parar e perguntar ao usuário.

## Hierarquia da Verdade
1. Código commitado e arquivos em disco (`path:line`).
2. `AGENTS.md` do projeto e `docs/decisoes/`.
3. Convenções gerais.
- Toda afirmação factual sobre o código cita `path:line`; o não verificado é `assumption`/`unverified`.

## Protocolo de Perguntas (4-tier)
- T1: "Entendi X como Y, confere?" antes de mudanças de alto custo.
- T2/T3: `question` tool com 2–4 opções, recomendado primeiro com `(Recommended)`; agrupar perguntas num único call.
- T4: 1 pergunta por vez, máx. 3 níveis, parar na convergência.

## Idioma
- Usuário: português (pt-BR), direto, sem filler.
- Prompts de subagentes: inglês técnico conciso.
- Código, comentários, docstrings, commits: inglês.
