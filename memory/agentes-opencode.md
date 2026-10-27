---
description: >-
  Politica dos agentes customizados do opencode-orchestrator: sem pin de modelo, sem plano hardcoded, sequencia
  obrigatoria e isolamento de tooling
label: agentes-opencode
limit: 5000
read_only: false
---
# opencode-orchestrator: politica de agentes (2026-10-13)
Fonte: ~/Workspace/opencode-orchestrator/agents/*.md (symlink em ~/.config/opencode/agents/).

REGRAS (nao reintroduzir):
1. ZERO pin de "model:" no frontmatter. Agentes herdam o modelo da sessao — modelo indisponivel
   nunca quebra subagente. Custo se controla por ROTEAMENTO, nao por pin.
2. ZERO hardcode de plano nos prompts: sem path, sem frontmatter "status:", sem "Ctrl+G", sem
   "[a] Aprovar". Planos seguem a convencao vigente em runtime.
3. Sequencia OBRIGATORIA nos agentes principais (orchestrator, architect):
   Recon (@explorer/@librarian) -> Design (@architect) -> Implement (closed specs) -> Verify.
   Nenhum dispatch que modifique codigo antes do design estar fechado.
4. Tooling: negar browser/cloudflare/omni-remoto por padrao; so o especialista recebe.
   explorer e reviewer tem write/edit: false (read-only estrutural).
4b. ROSTER completo no fluxo (orchestrator.md secao 4 e architect.md secao Delegation): os 16
   agentes do repo + o nativo general tem objetivo mapeado. librarian e coluna do fluxo
   (antes do recon, no design gate, depois de verificar) - memoria e passo, nao fase.
   NOTA: build/plan/explore nao existem mais no registry (confirmado na lista de subagentes
   desta sessao) - nao roteie para eles.
5. Architecture of the security slice (2026-10-13): sec-audit/sec-pentest/sec-fix foram migrados
   de mode:primary hidden:true para mode:subagent delegavel, com bash:false em todos. Consequencia
   deliberada: scanners e testes sao tarefa do primario, executados a partir das linhas
   SCANNER_REQUESTED / VERIFY_REQUESTED emitidas pelos subagentes. O orchestrator.md secao 7 faz
   o roteamento direto; o antigo 'sugerir, nunca auto-invocar' foi removido.
6. Cache de recon: explorer emite recon_map (entry_points, key_modules, conventions,
   build_test_cmds com path:line); librarian persiste em '## Recon Map' do bloco project e o
   le antes do recon. Causa medida que motivou: 'no_output' = 15 de 27 breaches.
7. Architect tem Response Standard de 9 secoes (RESUMO/CONTEXTO/OPCOES/ANALISE/DIAGRAMA/
   RECOMENDACAO/RISCOS/EXECUCAO/PERGUNTAS) — o usuario gosta muito dele; manter.

sec-*.md foram copiados de ~/.config/opencode/agents/ para o repo (agents/) - antes viviam
so fora do versionamento. O frontmatter antigo (permissions:/steps:) foi migrado para
tools: + mode:subagent; nao reintroduzir permissions:/steps:/hidden: true.

Plugin plan-panel: DESATIVADO (movido para ~/.config/opencode/plugins/disabled/). install.sh so
instala com --with-plan-panel. O codigo-fonte permanece em plugins/plan-panel/.

Medicao: python3 ~/tools/orchestrator_analytics/cli.py (ou /analytics cli | /analytics alerts).
Analytics (2026-10-13): adicionados E1 (routing breakdown + breach root cause) e E2 (alerts com
acao sugerida). Dois bugs corrigidos: (a) targets de dispatch liam a chave 'agent', que nunca
existe - o campo real e subagent_type (task) / to (mc_dispatch) - logo havia 0 delegacoes
detectadas; (b) IER descartava agentes nao classificados (86M tokens, ~30%), inflating the ratio.
Agora: 15 delegacoes, coverage 100%, IER 0.62 (era 0.54 sobre so 70% dos tokens).
Thresholds por env em orchestrator_analytics/config.py (ALERT_*).
build/plan/explore sao LEGACY no motor: nao existem mais como agentes delegaveis, mas continuam
classificados para as sessoes historicas.
Historico: @build 11 calls = 63% dos tokens / 85% do custo; @plan 19 calls; breach alto em
@build (72.7%) e @explore nativo (77.8%). Custom agents = ~7M tokens, $0.
