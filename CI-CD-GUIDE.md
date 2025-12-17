# Guia de CI/CD

Este guia explica o pipeline de integração contínua e deploy da aplicação ALM Full Stack.

## Visão Geral

O projeto utiliza GitHub Actions para automatizar testes, build e deploy. O pipeline é dividido em dois workflows principais:

- **Workflow de CI**: Executa testes e validações nas mudanças de código
- **Workflow de Deploy**: Constrói imagens Docker e faz deploy em staging ou produção

## Workflows

### Workflow de CI (CI - Full Stack)

O workflow de CI roda automaticamente quando você faz push de código para os branches principais ou cria pull requests. Ele executa os seguintes passos:

1. **Detecção de Mudanças**: Analisa quais partes do código mudaram (backend, frontend ou banco de dados)
2. **CI do Backend**: Executa verificações de linting com Black e Ruff no código Python
3. **CI do Frontend**: Instala dependências, executa linting e faz build da aplicação React
4. **Testes de Integração**: Inicia todos os serviços com Docker Compose e verifica se funcionam juntos
5. **Validação do Docker Compose**: Garante que a configuração do docker-compose.yml está válida

O workflow de CI está configurado para não executar quando você cria tags de versão. Isso evita execuções duplicadas ao fazer deploy em produção.

#### Quando o CI Roda

- Push para os branches main, develop ou master
- Pull requests direcionados para main, develop ou master
- Acionamento manual via interface do GitHub Actions

#### Quando o CI Não Roda

- Push de tags de versão (v1.0.0, v1.2.3, etc.)

### Workflow de Deploy (Deploy - Full Stack)

O workflow de deploy cuida da construção de imagens Docker e do deploy da aplicação. Ele consiste em vários jobs:

#### 1. Build de Imagens Docker

Constrói imagens Docker separadas para os serviços de backend e frontend. Cada imagem é tagueada com múltiplos formatos:

- Nome do branch (para pushes de branches)
- Versão semântica (para releases tagueadas)
- SHA do commit Git
- `latest` (para o branch padrão)

As imagens são enviadas para o GitHub Container Registry em `ghcr.io/guilhermebes/alm-fullstack/`.

#### 2. Deploy para Staging

Roda automaticamente quando código é enviado para o branch main. Este job:

- Faz checkout do código mais recente
- Executa comandos de deploy (atualmente passos de exemplo)
- Executa migrações do banco de dados
- Verifica se o deploy foi bem-sucedido

#### 3. Deploy para Produção

Dispara apenas quando você cria uma tag de versão começando com `v` (por exemplo, v1.0.0). Este job:

- Cria um registro de deployment no GitHub
- Executa comandos de deploy de produção
- Executa migrações do banco de dados
- Verifica o deployment
- Atualiza o status do deployment
- Faz rollback automaticamente se o deploy falhar

#### 4. Smoke Tests

Roda após o deploy de staging para verificar funcionalidades básicas da aplicação deployada.

## Criando uma Release de Produção

Siga estes passos para fazer deploy de uma nova versão em produção:

### Passo 1: Garantir que o Código Está Pronto

Certifique-se de que todas as mudanças estão commitadas e enviadas para o branch main. O workflow de CI deve ter sido concluído com sucesso.

### Passo 2: Criar uma Tag de Versão

Escolha um número de versão semântica apropriado seguindo o formato `vMAJOR.MINOR.PATCH`:

- **MAJOR**: Incrementar para mudanças que quebram compatibilidade
- **MINOR**: Incrementar para novas funcionalidades (compatíveis com versões anteriores)
- **PATCH**: Incrementar para correções de bugs

Crie e envie a tag:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### Passo 3: Monitorar o Deploy

O workflow de deploy iniciará automaticamente. Você pode monitorar o progresso:

```bash
gh run list --limit 5
gh run watch <run-id>
```

Ou visualizar na aba Actions do seu repositório no GitHub.

### Passo 4: Verificar o Deploy

Quando o workflow for concluído, verifique se:

- Ambas as imagens Docker foram construídas com sucesso
- O job de deploy de produção foi concluído
- Todos os passos de verificação passaram

Você pode ver os detalhes do deploy com:

```bash
gh run view <run-id>
```

## Ambientes

### Staging

O ambiente de staging é usado para testar mudanças antes de chegarem à produção. Faz deploy automaticamente quando código é enviado para o branch main.

- **URL do Ambiente**: https://staging.alm.example.com (exemplo)
- **Gatilho**: Push para o branch main
- **Propósito**: Testes e validação pré-produção

### Produção

O ambiente de produção serve usuários reais e deve receber apenas código completamente testado.

- **URL do Ambiente**: https://alm.example.com (exemplo)
- **Gatilho**: Tags de versão (v*)
- **Propósito**: Aplicação em produção servindo usuários finais
- **Proteção**: Inclui rollback automático em caso de falha

## Imagens Docker

Cada deploy constrói duas imagens Docker:

### Imagem do Backend

Construída a partir de `alm-backend/src/Dockerfile` e inclui:

- Código da aplicação Python
- Submódulo PyxLSTM
- Servidor FastAPI
- Modelos e migrações do banco de dados

### Imagem do Frontend

Construída a partir de `alm-frontend/Dockerfile` e inclui:

- Aplicação React
- Configuração de build do Vite
- Assets otimizados para produção

Ambas as imagens são armazenadas no GitHub Container Registry e podem ser baixadas com:

```bash
docker pull ghcr.io/guilhermebes/alm-fullstack/backend:v1.0.0
docker pull ghcr.io/guilhermebes/alm-fullstack/frontend:v1.0.0
```

## Resumo do Comportamento dos Workflows

| Evento | CI Roda | Deploy Roda | Deploy Staging | Deploy Produção |
|--------|---------|-------------|----------------|-----------------|
| Push para main | Sim | Sim | Sim | Não |
| Pull request | Sim | Não | Não | Não |
| Push tag v* | Não | Sim | Não | Sim |
| Acionamento manual | Sim | Sim | Configurável | Configurável |

## Tarefas Comuns

### Fazendo Deploy de um Hotfix

1. Crie um branch a partir da última tag de produção
2. Faça as mudanças necessárias
3. Crie um pull request para main
4. Após o merge, crie uma nova tag de versão patch (ex: v1.0.1)

### Fazendo Rollback de um Deploy

Se um deploy de produção falhar, o workflow tentará fazer rollback automaticamente. Para rollback manual:

1. Identifique a última tag de versão que estava funcionando
2. Crie uma nova tag apontando para aquele commit:

```bash
git tag -a v1.0.2 <commit-anterior-funcionando> -m "Rollback para versão anterior"
git push origin v1.0.2
```

### Visualizando Histórico de Deploys

```bash
gh run list --workflow=deploy.yml --limit 20
```

### Verificando Logs de Build

```bash
gh run view <run-id> --log
```

## Solução de Problemas

### Workflow de CI Falha no Linting

Revise os erros de linting nos logs do workflow e corrija-os localmente:

```bash
# Linting do backend
cd alm-backend/src
black app/ tests/
ruff check app/ tests/ --fix

# Linting do frontend
cd alm-frontend
npm run lint -- --fix
```

### Build do Docker Falha

Causas comuns:

- Inicialização de submódulo faltando
- Sintaxe inválida do Dockerfile
- Dependências de build faltando

Verifique os logs de build para mensagens de erro específicas.

### Workflow de Deploy Não Dispara

Verifique se:

- A tag segue o formato correto (começa com 'v')
- A tag foi enviada para o repositório remoto
- A sintaxe do arquivo de workflow está válida

### Imagens Não Encontradas no Registry

Certifique-se de ter as permissões corretas para acessar o GitHub Container Registry. Você pode precisar se autenticar:

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

## Customização

### Atualizando URLs dos Ambientes

Edite `.github/workflows/deploy.yml` e atualize as URLs dos ambientes:

```yaml
environment:
  name: production
  url: https://seu-dominio-real.com
```

### Adicionando Passos de Deploy

Os jobs de deploy atualmente contêm passos de exemplo. Substitua os comandos echo por comandos reais de deploy:

```yaml
- name: Deploy to production
  run: |
    ssh user@prod-server << 'EOF'
      cd /app/alm
      docker compose pull
      docker compose up -d
    EOF
```

### Configurando Ambientes Protegidos

No GitHub, navegue até Settings > Environments para configurar:

- Revisores obrigatórios antes do deploy
- Restrições de branch para deploy
- Secrets do ambiente

## Melhores Práticas

1. **Sempre teste em staging primeiro**: Deixe as mudanças rodarem em staging antes de criar uma tag de produção
2. **Use versionamento semântico**: Siga os princípios de semver para números de versão
3. **Escreva mensagens de tag significativas**: Descreva o que está incluído na release
4. **Monitore os deploys**: Acompanhe a execução do workflow para identificar problemas cedo
5. **Mantenha os workflows atualizados**: Revise e atualize as configurações dos workflows conforme o projeto evolui
6. **Documente procedimentos de deploy**: Mantenha este guia atualizado com quaisquer passos customizados de deploy

## Recursos Adicionais

- [Documentação do GitHub Actions](https://docs.github.com/en/actions)
- [Documentação do Docker](https://docs.docker.com/)
- [Versionamento Semântico](https://semver.org/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
