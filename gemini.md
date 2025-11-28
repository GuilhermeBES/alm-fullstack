## Resumo das Alterações e Estado Atual para Conexão do Gráfico Sunburst

Este documento resume as modificações realizadas e o estado atual do projeto para conectar a página de administração (AdminPage) do frontend a um endpoint do backend, visando exibir um gráfico Sunburst.

### Objetivo Inicial
Conectar a `AdminPage.tsx` do frontend a um endpoint do backend para buscar dados de alocação de portfólio e exibi-los no componente `SunburstChart.tsx`.

### Estado do Frontend
*   Os componentes `AdminPage.tsx` e `SunburstChart.tsx` estão configurados para funcionar.
*   `AdminPage.tsx` já tenta buscar dados do endpoint `/portfolio-allocation` e possui uma função (`transformDataForSunburst`) para formatar esses dados para o `SunburstChart`.
*   O `SunburstChart.tsx` espera um formato de dados hierárquico específico.

### Alterações no Backend (`alm-backend`)
1.  **Esquemas Pydantic:** Foram adicionados os esquemas `Asset` e `Wallet` (equivalentes às interfaces do frontend) ao arquivo `alm-backend/src/app/schemas/inference.py`.
2.  **Novo Endpoint:** Foi criado um novo endpoint GET `/portfolio-allocation` no arquivo `alm-backend/src/app/routers/inference.py`.
    *   Este endpoint tenta buscar dados reais via `market_data_service.get_portfolio_data()`.
    *   Em caso de erro, retorna dados estáticos (fallback) contendo 5 ativos: PETR4.SA (40%), VALE3.SA (25%), ITUB4.SA (15%), WEGE3.SA (10%) e BTC-USD (10%).
    *   O Bitcoin foi adicionado tanto ao `market_data_service.py` quanto ao fallback do endpoint.
3.  **Problema de Instalação de Dependências (`numpy` e `pandas`):**
    *   Ao tentar iniciar o servidor, ocorreu um erro `ModuleNotFoundError: No module named 'numpy'`.
    *   A causa raiz foi a ausência de um compilador C++ no sistema do usuário, necessário para a instalação de bibliotecas como `numpy` e `pandas`.
4.  **Solução Temporária (para iniciar o servidor):**
    *   Para contornar o problema do compilador e permitir que o servidor inicie, as linhas `import numpy as np` e `import pandas as pd` foram **comentadas** no arquivo `alm-backend/src/app/services/inference_service.py`.
    *   **ATENÇÃO:** Esta é uma solução temporária. As funcionalidades de inferência de Machine Learning (que dependem de `numpy` e `pandas`) estarão desabilitadas com essa alteração.

### Estado Atual
*   ✅ O backend possui o endpoint `/portfolio-allocation` que busca **dados REAIS** via Yahoo Finance.
*   ✅ O Bitcoin (BTC-USD) está incluído e aparece com preço real no gráfico.
*   ✅ Todas as ações (PETR4.SA, VALE3.SA, ITUB4.SA, WEGE3.SA, BTC-USD) são buscadas do banco de dados SQLite.
*   ✅ O `market_data_service` calcula retornos e volatilidade históricos baseados em dados reais de 1 ano.
*   ✅ O servidor backend está rodando em http://localhost:8000 com auto-reload habilitado.
*   ✅ O frontend está pronto para consumir e exibir esses dados no gráfico Sunburst.

### Estado Atual - Tudo Funcionando! ✅

1.  ✅ **Backend**: Rodando em http://localhost:8000 e http://192.168.1.19:8000
2.  ✅ **Frontend**: Rodando em http://localhost:3000 e http://192.168.1.19:3000
3.  ✅ **Dados Reais**: Bitcoin e ações com preços via Yahoo Finance
4.  ✅ **Novos Gráficos**: Dashboard completo com visualizações
5.  ✅ **Autenticação**: Login funcionando (`admin@alm.com` / `admin123`)
6.  ✅ **Acesso em Rede**: Frontend e Backend acessíveis de qualquer dispositivo na rede local

### Acessar a Aplicação

- **Local**: http://localhost:3000
- **Rede Local**: http://192.168.1.19:3000

### Credenciais de Acesso

- **Email**: admin@alm.com
- **Senha**: admin123
- **Role**: admin

### Como Iniciar o Servidor Backend (Desenvolvimento)

**Opção 1: Usar o script batch (Windows - RECOMENDADO)**
```bash
cd C:\ALM\alm-backend
start-dev.bat
```

**Opção 2: Comando direto**
```bash
cd C:\ALM\alm-backend\src
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

**Nota Importante:**
- O servidor roda **SEM auto-reload** para maior estabilidade
- Quando fizer alterações no código, reinicie o servidor manualmente:
  1. Pressione `Ctrl+C` para parar
  2. Execute `start-dev.bat` novamente (ou o comando python)
- Isso evita problemas com o auto-reload em background no Windows

---

## Atualização do Dashboard com Novos Gráficos

A página do Dashboard (`alm-frontend/src/pages/Dashboard/Dashboard.tsx`) foi completamente reformulada para incluir visualizações mais abrangentes e informativas.

### Novos Componentes Criados

1. **AccumulationChart.tsx** - Gráfico de linha temporal (2020-2050)
   - Visualiza a projeção de crescimento do portfólio ao longo de 30 anos
   - Utiliza recharts LineChart com dados mockados
   - Mostra aportes mensais + crescimento composto
   - Tooltips interativos com valores formatados

2. **MonthlyDataTable.tsx** - Tabela de dados mensais
   - Exibe os últimos 6 meses de movimentação
   - Colunas: Mês, Saldo, Variação (%)
   - Variações positivas em verde, negativas em vermelho
   - Paginação para navegação entre períodos

3. **AllocationBarChart.tsx** - Gráfico de barras de alocação
   - Mostra distribuição de investimentos por categoria
   - Categorias: Cryptocurrencies, E-commerce, Retail, Energy
   - Barras horizontais com cores personalizadas
   - Valores em reais brasileiros

4. **RiskSection.tsx** - Seção completa de análise de riscos
   - Gráfico de barras mostrando níveis de risco (0-100)
   - Tabela lateral com descrições detalhadas
   - Categorias: Investimentos, Países, Câmbio, Taxas, Criptomoedas, Concentração
   - Controles de período (Hoje, 1m, 3m, 1a, Total)

### Biblioteca Instalada

- **recharts** (^2.x): Biblioteca de gráficos React baseada em D3
  - Instalada via `npm install recharts`
  - Fornece componentes prontos: LineChart, BarChart, Tooltip, etc.

### Estrutura do Dashboard Atualizado

```
Dashboard
├── Cards de Métricas (Montante, Aporte, Capitalização, Pontos)
├── Layout de Duas Colunas
│   ├── Coluna Esquerda
│   │   ├── Gráfico de Fase de Acumulação (linha temporal)
│   │   └── Tabela de Dados Mensais
│   └── Coluna Direita
│       ├── Tabela de Investimentos
│       └── Heatmap de Desempenho (com dados reais)
├── Seção de Investment Allocation (gráfico de barras)
└── Seção de Riscos (gráfico + tabela descritiva)
```

### Visualização

Acesse http://localhost:3000 para ver o Dashboard completo com:
- ✅ Gráficos responsivos e interativos
- ✅ Dados mockados para demonstração
- ✅ Estilos consistentes com o design fornecido
- ✅ Tooltips e animações suaves

---

## Containerização e Orquestração com Docker e Makefile

Para simplificar o desenvolvimento e a implantação, os microsserviços `alm-frontend` e `alm-backend` foram containerizados e orquestrados usando Docker e Docker Compose, com um `Makefile` para facilitar os comandos.

### Alterações Realizadas

*   **`Dockerfile` para `alm-frontend`**: Foi criado um `Dockerfile` em `alm-frontend/Dockerfile` para construir a aplicação React. Ele utiliza uma abordagem multi-stage para criar uma imagem de produção otimizada com Nginx.
*   **`docker-compose.yml` Raiz**: Um arquivo `docker-compose.yml` foi criado na raiz do projeto (`C:\ALM`) para orquestrar ambos os serviços:
    *   **`alm-frontend`**: Define o serviço de frontend, construindo a imagem a partir do diretório `alm-frontend` e expondo a porta `80`.
    *   **`alm-backend`**: Referencia o diretório `alm-backend/src` para construir o serviço de backend, expondo a porta `8000`.
*   **`Makefile`**: Um `Makefile` foi criado na raiz do projeto (`C:\ALM`) para encapsular os comandos do Docker Compose e simplificar as operações.

### Como Usar

Certifique-se de estar no diretório raiz do projeto (`C:\ALM`) no seu terminal.

1.  **Verificar Instalação do Docker**: Antes de tudo, certifique-se de que o **Docker Desktop** esteja instalado e em execução no seu sistema. Se não estiver, baixe e instale-o do [site oficial do Docker](https://www.docker.com/products/docker-desktop/). Após a instalação/inicialização, **reinicie o seu terminal** para que as variáveis de ambiente sejam atualizadas.

2.  **Usando o `Makefile` (Recomendado se 'make' estiver instalado):**

    *   **Construir as imagens:**
        ```bash
        make build
        ```
    *   **Iniciar os serviços (em segundo plano):**
        ```bash
        make up
        ```
    *   **Parar os serviços:**
        ```bash
        make down
        ```
    *   **Visualizar logs em tempo real:**
        ```bash
        make logs
        ```
    *   **Limpar (parar, remover containers, volumes e imagens):**
        ```bash
        make clean
        ```
    *   **Reconstruir e iniciar tudo:**
        ```bash
        make rebuild
        ```

3.  **Usando Comandos `docker compose` Diretamente (se 'make' não estiver disponível):**

    Se o comando `make` não for reconhecido, você pode executar os comandos `docker compose` diretamente:

    *   **Construir as imagens e iniciar os serviços (em segundo plano):**
        ```bash
        docker compose build && docker compose up -d
        ```
    *   **Parar e remover os serviços:**
        ```bash
        docker compose down
        ```

### Acessando as Aplicações

*   **Frontend**: Após iniciar os serviços, o frontend deverá estar acessível em `http://localhost`.
*   **Backend**: O backend estará disponível em `http://localhost:8000`.

### Observação sobre `alm-banco-de-dados`

O repositório `alm-banco-de-dados` contém scripts e documentação. Se a intenção for containerizar uma instância de banco de dados para ser usada pelo `alm-backend`, será necessário configurar um novo serviço no `docker-compose.yml` raiz, especificando o tipo de banco de dados (por exemplo, PostgreSQL, MySQL) e suas configurações.