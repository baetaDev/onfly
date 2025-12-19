# Travel Orders Service - Microsserviço Laravel

Microsserviço Laravel para gerenciamento de pedidos de viagem corporativa.

## 📋 Pré-requisitos

- Docker Desktop instalado e rodando
- Docker Compose (incluso no Docker Desktop)

## 🚀 Como executar

### 1. Clone o repositório

```bash
git clone https://github.com/baetaDev/onfly.git
cd onfly
```

### 2. Inicie os containers

```bash
docker-compose up -d --build
```

Este comando irá:
- Construir a imagem da aplicação
- Instalar automaticamente o Laravel (se necessário)
- Configurar o banco de dados MySQL
- Iniciar todos os serviços

### 3. Aguarde a inicialização

Na primeira execução, o Laravel será instalado automaticamente. Aguarde alguns minutos para:
- Download e instalação das dependências
- Configuração do banco de dados
- Geração da chave da aplicação

### 4. Acesse a aplicação

- **Aplicação Web:** http://localhost:8000
- **Banco de dados MySQL:** localhost:3306

## 🔧 Credenciais do Banco de Dados

- **Host:** localhost (ou `db` de dentro dos containers)
- **Porta:** 3306
- **Database:** onfly
- **Username:** onfly
- **Password:** onfly
- **Root Password:** onfly

## 📁 Estrutura do Projeto

```
onfly/
├── app/                    # Código da aplicação Laravel
├── database/               # Migrations e seeders
├── docker/                 # Configurações Docker
│   ├── nginx/             # Configuração Nginx
│   ├── php/               # Configurações PHP e PHP-FPM
│   └── mysql/             # Configurações MySQL
├── routes/                 # Rotas da aplicação
│   ├── api.php            # Rotas da API REST
│   └── web.php            # Rotas web
├── Dockerfile             # Imagem da aplicação
└── docker-compose.yml     # Orquestração dos serviços
```


### Executar comandos Artisan

```bash
docker-compose exec app php artisan <comando>
```

Exemplos:
```bash
docker-compose exec app php artisan migrate
docker-compose exec app php artisan make:controller NomeController
docker-compose exec app php artisan route:list
```

### Acessar o container da aplicação

```bash
docker-compose exec app bash
```

### Acessar o MySQL

```bash
docker-compose exec db mysql -u onfly -ponfly onfly
```

### Parar os containers

```bash
docker-compose down
```

### Parar e remover volumes (apaga dados do banco)

```bash
docker-compose down -v
```

### Reiniciar os containers

```bash
docker-compose restart
```

## 🔐 Ambiente Preparado

- ✅ **MySQL** configurado e rodando
- ✅ **Laravel Sanctum** instalado para autenticação com tokens
- ✅ **PHPUnit** configurado para testes com MySQL
- ✅ **API Routes** configuradas em `routes/api.php`

## 🧪 Testes

O ambiente está configurado para executar testes automatizados com PHPUnit.

```bash
# Criar banco de testes
docker-compose exec db mysql -u onfly -ponfly -e "CREATE DATABASE IF NOT EXISTS onfly_test;"

# Executar testes
docker-compose exec app php artisan test
```

## 📝 Notas

- O Laravel é instalado automaticamente na primeira execução
- As migrations são executadas automaticamente quando o banco estiver disponível
- As permissões do diretório `storage` são configuradas automaticamente

### Erro de permissão no storage

```bash
docker-compose exec app chmod -R 775 storage bootstrap/cache
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
```

## 📚 Tecnologias

- **Framework:** Laravel 12
- **PHP:** 8.2
- **Web Server:** Nginx
- **Database:** MySQL 8.0
- **Autenticação:** Laravel Sanctum (configurado)
- **Testes:** PHPUnit (configurado)
- **Containerização:** Docker & Docker Compose
