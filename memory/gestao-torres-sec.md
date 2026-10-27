---
description: Watchlist de segurança para o projeto gestao-torres
label: gestao-torres-sec
limit: 5000
read_only: false
---
Aplicar proativamente a watchlist de /segurança.md (54 achados, 4 fases):
(1) Toda rota nova = Depends(get_current_user) (A-1).
(2) NUNCA: senha hardcoded no seed (A-4), str(exc) no handler 500 (A-7), except Exception→404 (C-1), dbSession.close() dentro de handler (C-2), datetime.now() naive em soft_delete (D-8), UPDATE de last_seen a cada request (D-1), commit separado entidade vs audit — usar no_commit=True + commit único (D-2).
(3) Uploads: limite de tamanho DURANTE a cópia, remover órfãos no rollback, resolve() contra UPLOADS_DIR (S-1/S-2/S-9).
(4) Soft-delete: helper único de rename, sufixo curto, truncate 255, mesmo formato entre models (R-1).
(5) Blockers/filtros NA query, não em Python (C-4).
(6) Cookies de auth com secure via env; JWT_SECRET sem default.
(7) Anti-padrões já rejeitados: APIRouter solto fora de ContextRouter, engine legado de templates em rota nova, |safe, senha fallback em scripts/default_seed.py. Corrigir achados se tocar na watchlist. Falsos positivos descartados não reabrir: geopy async ok, autoescape ligado, tojson|safe seguro, TOCTOU delete mitigado no service, race de nome mitigada por unique+UniqueViolation.
