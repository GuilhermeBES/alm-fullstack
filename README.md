# ALM - Asset Liability Management

Sistema completo de gestão de ativos e passivos (ALM) com frontend React, backend FastAPI e análise de dados.

## Estrutura do Projeto

Este é um **monorepo** que utiliza **Git Submodules** para organizar os diferentes componentes:

```
alm-fullstack/
├── alm-backend/          # Backend FastAPI (submodule)
├── alm-frontend/         # Frontend React + TypeScript (submodule)
├── alm-banco-de-dados/   # Scripts e dados (submodule)
├── docker-compose.yml    # Orquestração dos serviços
├── Makefile              # Comandos simplificados
└── README.md             # Este arquivo
```

## Requisitos

- **Git** (com suporte a longpaths habilitado)
- **Docker Desktop** instalado e em execução
- **Make** (opcional, mas recomendado)

## Clone do Projeto

### Opção 1: Clone com Submodules (Recomendado)

```bash
git clone --recurse-submodules https://github.com/GuilhermeBES/alm-fullstack.git
cd alm-fullstack
```

### Opção 2: Clone Normal + Inicializar Submodules

```bash
git clone https://github.com/GuilhermeBES/alm-fullstack.git
cd alm-fullstack
git submodule update --init --recursive
```

### Importante para Windows

Se você estiver no Windows e encontrar erros de "Filename too long", execute:

```bash
git config --global core.longpaths true
```

Depois re-clone o repositório ou execute:

```bash
git submodule update --init --recursive
```

## Como Rodar o Projeto

### Usando Make (Recomendado)

```bash
# Construir as imagens Docker
make build

# Iniciar todos os serviços
make up

# Ver logs em tempo real
make logs

# Parar os serviços
make down

# Limpar tudo (containers, volumes, imagens)
make clean

# Reconstruir e reiniciar
make rebuild
```

### Usando Docker Compose Diretamente

```bash
# Construir e iniciar
docker compose up -d --build

# Parar
docker compose down

# Ver logs
docker compose logs -f
```

## Acessar a Aplicação

Após iniciar os serviços:

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **Documentação API**: http://localhost:8000/docs

### Credenciais Padrão

- **Email**: admin@alm.com
- **Senha**: admin123
- **Role**: admin

## Desenvolvimento Local (Sem Docker)

### Backend

```bash
cd alm-backend/src
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend

```bash
cd alm-frontend
npm install
npm run dev
```

## Atualizando os Submodules

Quando houver atualizações nos repositórios dos submodules:

```bash
# Atualizar todos os submodules
git submodule update --remote --merge

# Ou atualizar um submodule específico
cd alm-backend
git pull origin main
cd ..
```

## Trabalhando com Submodules

### Fazer Mudanças em um Submodule

```bash
# 1. Entre no diretório do submodule
cd alm-backend

# 2. Crie uma branch e faça suas mudanças
git checkout -b minha-feature
# ... faça suas alterações ...
git add .
git commit -m "feat: adiciona nova feature"

# 3. Push para o repositório do submodule
git push origin minha-feature

# 4. Volte para o repositório principal
cd ..

# 5. Commite a atualização do submodule
git add alm-backend
git commit -m "chore: atualiza alm-backend"
git push
```

## Estrutura dos Serviços

### Backend (alm-backend)
- FastAPI
- SQLite (desenvolvimento)
- Yahoo Finance API
- Autenticação JWT

### Frontend (alm-frontend)
- React 18
- TypeScript
- Vite
- Recharts para visualizações
- Tailwind CSS

### Banco de Dados (alm-banco-de-dados)
- Scripts de webscraping
- Documentação do schema
- Dados históricos

## Problemas Comuns

### Submodules vazios após clone

```bash
git submodule update --init --recursive
```

### Erro "Filename too long" no Windows

```bash
git config --global core.longpaths true
```

### Docker não inicia

1. Verifique se o Docker Desktop está rodando
2. Reinicie o Docker Desktop
3. Verifique se as portas 3000 e 8000 estão livres

### Mudanças não aparecem no container

```bash
# Reconstruir as imagens
docker compose down
docker compose up -d --build
```

## Links Úteis

- [Repositório Backend](https://github.com/GuilhermeBES/alm-backend)
- [Repositório Frontend](https://github.com/GuilhermeBES/alm-frontend)
- [Repositório Banco de Dados](https://github.com/GuilhermeBES/alm-banco-de-dados)

## Contribuindo

1. Fork o repositório principal e os submodules necessários
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença

Este projeto é privado e proprietário.
