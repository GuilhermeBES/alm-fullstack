# 🚀 Guia de CI/CD - ALM Project

## 📋 Índice
- [Visão Geral](#visão-geral)
- [Estrutura de Workflows](#estrutura-de-workflows)
- [Configuração Inicial](#configuração-inicial)
- [Como Usar](#como-usar)
- [Secrets Necessários](#secrets-necessários)
- [Ambientes](#ambientes)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

O projeto ALM possui um pipeline completo de CI/CD distribuído em 3 níveis:

1. **Backend** (`alm-backend/.github/workflows/`)
   - CI: Lint, testes, security scan, build Docker
   - CD: Push para GHCR, deploy staging/production

2. **Frontend** (`alm-frontend/.github/workflows/`)
   - CI: Lint, type check, testes, build
   - CD: Push para GHCR, deploy staging/production

3. **Monorepo** (`.github/workflows/`)
   - CI Full: Orquestra CIs de todos os submódulos
   - Deploy: Deploy coordenado de toda stack

---

## 📁 Estrutura de Workflows

```
ALM/
├── .github/workflows/
│   ├── ci-full.yml          # CI completo (orquestrador)
│   └── deploy.yml           # Deploy coordenado
│
├── alm-backend/.github/workflows/
│   ├── ci.yml               # CI do backend
│   └── cd.yml               # CD do backend
│
└── alm-frontend/.github/workflows/
    ├── ci.yml               # CI do frontend
    └── cd.yml               # CD do frontend
```

---

## ⚙️ Configuração Inicial

### 1. Habilitar GitHub Actions

Nos **3 repositórios** (ALM, alm-backend, alm-frontend):

1. Acesse: `Settings` → `Actions` → `General`
2. Habilite: **Allow all actions and reusable workflows**
3. Em **Workflow permissions**, selecione: **Read and write permissions**

### 2. Configurar Secrets

#### No repositório principal (ALM):

```bash
# GitHub Settings → Secrets and variables → Actions → New repository secret
```

**Secrets necessários:**

| Secret | Descrição | Exemplo |
|--------|-----------|---------|
| `API_URL` | URL da API em produção | `https://api.alm.com` |
| `DEPLOY_SSH_KEY` | Chave SSH para deploy | (chave privada) |
| `DEPLOY_HOST` | Host do servidor | `user@prod-server.com` |

#### Nos submódulos (alm-backend, alm-frontend):

Os secrets são herdados do repositório principal, mas você pode adicionar secrets específicos se necessário.

### 3. Configurar Ambientes

Criar ambientes no GitHub:

1. `Settings` → `Environments` → `New environment`
2. Criar 2 ambientes:
   - **staging** (sem proteção)
   - **production** (com aprovação manual)

Para **production**:
- Ativar **Required reviewers** (1-2 pessoas)
- Adicionar **Deployment branches**: somente tags `v*`

---

## 🎮 Como Usar

### CI (Execução Automática)

#### Quando é executado:
- ✅ Push para `main`, `develop`, ou `feat/*`
- ✅ Pull Request para `main` ou `develop`
- ✅ Manualmente via GitHub UI

#### O que faz:

**Backend CI:**
```yaml
1. Lint (Black + Ruff)
2. Type check (MyPy)
3. Tests (pytest) em Python 3.11 e 3.13
4. Coverage report
5. Security scan (Bandit)
6. Build Docker image
```

**Frontend CI:**
```yaml
1. Lint (ESLint)
2. Type check (TypeScript)
3. Tests (Vitest) em Node 18 e 20
4. Build production
5. Build Docker image
```

**CI Full (Monorepo):**
```yaml
1. Detecta mudanças
2. Executa CI do backend (se alterado)
3. Executa CI do frontend (se alterado)
4. Testes de integração (Docker Compose)
5. Valida docker-compose.yml
```

### CD (Deploy)

#### Deploy para Staging

**Trigger:** Push para `main`

```bash
git push origin main
```

Fluxo:
1. ✅ CI passa
2. 🏗️ Build das imagens Docker
3. 📤 Push para `ghcr.io/seu-usuario/alm/*`
4. 🚀 Deploy automático para staging
5. ✅ Health checks

#### Deploy para Production

**Trigger:** Criar tag `v*`

```bash
# 1. Criar tag
git tag v1.0.0

# 2. Push da tag
git push origin v1.0.0
```

Fluxo:
1. ✅ CI passa
2. 🏗️ Build das imagens
3. 📤 Push com tag versionada
4. ⏸️ **Aguarda aprovação manual**
5. 🚀 Deploy para produção
6. ✅ Health checks
7. ↩️ Rollback automático se falhar

---

## 🔐 Secrets Necessários

### Obrigatórios (já fornecidos pelo GitHub):

- `GITHUB_TOKEN` - Token automático do GitHub
- `GITHUB_ACTOR` - Usuário que disparou o workflow

### Opcionais (para deploy real):

#### Para deploy SSH:

```bash
# Gerar chave SSH
ssh-keygen -t ed25519 -C "github-actions"

# Adicionar como secret
gh secret set DEPLOY_SSH_KEY < ~/.ssh/id_ed25519
gh secret set DEPLOY_HOST --body "user@servidor.com"
```

#### Para serviços cloud:

```bash
# AWS
gh secret set AWS_ACCESS_KEY_ID --body "AKIA..."
gh secret set AWS_SECRET_ACCESS_KEY --body "..."

# Railway
gh secret set RAILWAY_TOKEN --body "..."

# Render
gh secret set RENDER_API_KEY --body "..."
```

---

## 🌍 Ambientes

### Staging

- **URL:** `https://staging.alm.example.com`
- **Deploy:** Automático em push para `main`
- **Database:** Banco de dados de staging (separado)
- **Purpose:** Testes antes de produção

### Production

- **URL:** `https://alm.example.com`
- **Deploy:** Manual, via tags `v*`
- **Database:** Banco de dados de produção
- **Protection:** Requer aprovação manual

---

## 🎛️ Executar Manualmente

### Via GitHub UI:

1. Acesse: `Actions` → Selecione workflow
2. Clique em: `Run workflow`
3. Escolha a branch
4. Clique em: `Run workflow`

### Via GitHub CLI:

```bash
# CI Full
gh workflow run ci-full.yml

# Deploy específico
gh workflow run deploy.yml -f environment=staging

# Ver status
gh run list --workflow=ci-full.yml
```

---

## 🐛 Troubleshooting

### Erro: "Permission denied"

**Solução:**
```bash
# No repositório, vá em:
Settings → Actions → General → Workflow permissions
# Selecione: "Read and write permissions"
```

### Erro: "Submodule checkout failed"

**Solução:**
Os workflows já incluem `submodules: recursive`. Verifique se os submódulos estão acessíveis.

### Build Docker falha

**Verificar:**
```bash
# Local test
docker compose build
docker compose up
```

### Tests falhando

**Debug local:**
```bash
# Backend
cd alm-backend/src
pytest tests/ -v

# Frontend
cd alm-frontend
npm test
```

### Deploy não acontece

**Verificar:**
1. ✅ CI passou?
2. ✅ Tag criada corretamente? (`v1.0.0`)
3. ✅ Secrets configurados?
4. ✅ Ambiente production criado?

---

## 📊 Status Badges

Adicione badges ao README:

```markdown
[![CI - Full Stack](https://github.com/SEU-USUARIO/ALM/actions/workflows/ci-full.yml/badge.svg)](https://github.com/SEU-USUARIO/ALM/actions/workflows/ci-full.yml)
[![Deploy](https://github.com/SEU-USUARIO/ALM/actions/workflows/deploy.yml/badge.svg)](https://github.com/SEU-USUARIO/ALM/actions/workflows/deploy.yml)
```

---

## 🚀 Próximos Passos

1. **Configurar deploy real:**
   - Adicionar comandos SSH/API no `deploy.yml`
   - Configurar secrets de produção

2. **Adicionar testes E2E:**
   - Playwright/Cypress
   - Rodar após deploy staging

3. **Monitoring:**
   - Integrar Sentry/DataDog
   - Alertas de falha

4. **Performance:**
   - Lighthouse CI para frontend
   - Load tests para backend

---

## 📚 Recursos

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments)

---

**Última atualização:** Dezembro 2024
**Versão:** 1.0.0
