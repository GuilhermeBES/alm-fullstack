# 🚀 Configuração de Deploy - ALM Project

## 📋 Visão Geral

Os workflows de CD estão **prontos**, mas você precisa escolher onde fazer o deploy e configurar os comandos específicos.

---

## 🎯 Opções de Deploy

### **Opção 1: GitHub Container Registry (GHCR) - Já Configurado! ✅**

As imagens Docker já estão sendo enviadas automaticamente para:
- `ghcr.io/guilhermebes/alm-backend:latest`
- `ghcr.io/guilhermebes/alm-frontend:latest`

**O que acontece:**
- ✅ Push para `main` → Imagens com tag `:main` e `:latest`
- ✅ Tag `v1.0.0` → Imagens com tag `:v1.0.0`, `:1.0`, `:latest`

**Para usar as imagens:**
```bash
# Pull das imagens
docker pull ghcr.io/guilhermebes/alm-backend:latest
docker pull ghcr.io/guilhermebes/alm-frontend:latest

# Ou via docker-compose
docker compose pull
docker compose up -d
```

---

### **Opção 2: Deploy em Servidor (VPS/EC2) via SSH**

#### **1. Configurar Secrets**

No GitHub:
```bash
Settings → Secrets → Actions → New repository secret
```

Adicionar:
- `DEPLOY_SSH_KEY` - Chave privada SSH
- `DEPLOY_HOST` - Usuário e host (ex: `ubuntu@servidor.com`)
- `DEPLOY_PATH` - Caminho no servidor (ex: `/var/www/alm`)

#### **2. Editar workflows de deploy**

Substituir os comandos de deploy nos arquivos:
- `alm-backend/.github/workflows/cd.yml`
- `alm-frontend/.github/workflows/cd.yml`
- `.github/workflows/deploy.yml`

**Exemplo de deploy via SSH:**

```yaml
- name: Deploy to staging
  run: |
    # Configurar SSH
    mkdir -p ~/.ssh
    echo "${{ secrets.DEPLOY_SSH_KEY }}" > ~/.ssh/deploy_key
    chmod 600 ~/.ssh/deploy_key

    # Fazer deploy
    ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no ${{ secrets.DEPLOY_HOST }} << 'EOF'
      cd ${{ secrets.DEPLOY_PATH }}
      docker compose pull
      docker compose up -d --no-deps
      docker compose exec backend alembic upgrade head
    EOF
```

---

### **Opção 3: Deploy em Plataformas Cloud (Recomendado para começar)**

#### **Railway.app** (Mais fácil)

1. Conectar GitHub → Railway
2. Configurar variáveis de ambiente
3. Deploy automático em cada push

**Vantagens:**
- ✅ Deploy automático
- ✅ SSL grátis
- ✅ Logs integrados
- ✅ Free tier generoso

#### **Render.com**

Similar ao Railway, mas com Docker native.

**Como configurar:**
```yaml
# No workflow
- name: Deploy to Render
  run: |
    curl -X POST "https://api.render.com/deploy/srv-XXXXX?key=${{ secrets.RENDER_DEPLOY_HOOK }}"
```

#### **AWS ECS/Fargate**

Para produção em larga escala.

---

## 🔧 Configuração Atual dos Workflows

### **Backend CD** (`alm-backend/.github/workflows/cd.yml`)

```yaml
✅ Build Docker image
✅ Push para GHCR
⏸️  Deploy staging (precisa configurar)
⏸️  Deploy production (precisa configurar)
```

### **Frontend CD** (`alm-frontend/.github/workflows/cd.yml`)

```yaml
✅ Build Docker image com variáveis de ambiente
✅ Push para GHCR
⏸️  Deploy staging (precisa configurar)
⏸️  Deploy production (precisa configurar)
```

### **Full Deploy** (`.github/workflows/deploy.yml`)

```yaml
✅ Build de todos os serviços
✅ Push para GHCR
⏸️  Deploy coordenado (precisa configurar)
⏸️  Smoke tests (precisa configurar)
```

---

## 🎮 Como Testar o CD (Build de Imagens)

### **1. Testar build automático:**

```bash
# Push para main (dispara CD)
git push origin main

# Verificar no GitHub Actions
# As imagens serão enviadas para GHCR automaticamente
```

### **2. Testar deploy de versão:**

```bash
# Criar tag de versão
git tag v1.0.0
git push origin v1.0.0

# Isso vai:
# 1. Build das imagens
# 2. Push com tags versionadas
# 3. Aguardar aprovação manual (se configurado)
# 4. Deploy para produção (quando configurar)
```

### **3. Verificar imagens no GHCR:**

Acesse: `https://github.com/GuilhermeBES?tab=packages`

Você verá:
- `alm-backend` com tags
- `alm-frontend` com tags

---

## 🌍 Configurar Ambientes de Deploy

### **Staging** (Desenvolvimento)

```yaml
environment:
  name: staging
  url: https://staging.seudominio.com
```

**Variáveis de ambiente:**
- `DATABASE_URL` - Banco de staging
- `API_URL` - URL da API de staging
- `SECRET_KEY` - Secret key diferente de prod

### **Production** (Produção)

```yaml
environment:
  name: production
  url: https://seudominio.com
```

**Proteções:**
- ✅ Aprovação manual obrigatória
- ✅ Só permite deploy de tags `v*`
- ✅ Rollback automático se falhar

---

## 🔐 Secrets Necessários (Por Plataforma)

### **Deploy SSH:**
```bash
gh secret set DEPLOY_SSH_KEY < ~/.ssh/id_rsa
gh secret set DEPLOY_HOST --body "user@servidor.com"
gh secret set DEPLOY_PATH --body "/var/www/alm"
```

### **Railway:**
```bash
gh secret set RAILWAY_TOKEN --body "seu-token"
```

### **Render:**
```bash
gh secret set RENDER_DEPLOY_HOOK --body "https://api.render.com/deploy/..."
```

### **AWS:**
```bash
gh secret set AWS_ACCESS_KEY_ID --body "AKIA..."
gh secret set AWS_SECRET_ACCESS_KEY --body "..."
gh secret set AWS_REGION --body "us-east-1"
```

---

## ✅ Status Atual

```
✅ CI completo funcionando
✅ Build de imagens Docker (CD)
✅ Push para GitHub Container Registry
✅ Ambientes configurados (staging/production)
⏸️  Deploy automático (aguardando configuração)
```

---

## 🚀 Próximos Passos Recomendados

### **Fase 1 - Validar CI/CD básico (AGORA)**

```bash
# 1. Fazer push das correções
cd alm-backend
git add .github/
git commit -m "fix: Add token and submodule init to CD workflows"
git push

cd ../alm-frontend
git add .github/
git commit -m "fix: Add token to CD workflows"
git push

cd ..
git add .github/
git commit -m "fix: Add token and submodule init to deploy workflow"
git push

# 2. Verificar Actions
# https://github.com/GuilhermeBES/alm-fullstack/actions

# 3. Verificar imagens no GHCR
# https://github.com/GuilhermeBES?tab=packages
```

### **Fase 2 - Configurar deploy real (DEPOIS)**

Escolha uma opção:

**A) Railway (mais fácil):**
1. Criar conta em railway.app
2. Conectar repositório GitHub
3. Configurar variáveis de ambiente
4. Deploy automático

**B) Servidor próprio:**
1. Provisionar servidor (VPS/EC2)
2. Instalar Docker + Docker Compose
3. Configurar SSH keys
4. Editar workflows com comandos SSH

**C) AWS/GCP/Azure:**
1. Configurar infraestrutura
2. Adicionar secrets das clouds
3. Editar workflows com comandos específicos

---

## 📚 Recursos

- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Railway Deployments](https://docs.railway.app/deploy/deployments)
- [Render Deploy Hooks](https://render.com/docs/deploy-hooks)
- [Docker Compose Deploy](https://docs.docker.com/compose/production/)

---

**Última atualização:** Dezembro 2024
