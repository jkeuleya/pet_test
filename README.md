# Pet Vaccination API

A robust and scalable REST API for managing pets and their vaccination records, built with Ruby on Rails and optimized for high performance.

## 🚀 Features

- **Pet Management**: Full CRUD operations with validations
- **Vaccination Records**: Track vaccinations with automatic expiry management
- **Background Jobs**: Automatic notifications via Sidekiq when vaccinations expire
- **Versioned API**: Support for multiple versions (v1)
- **Pagination**: Efficient handling of large datasets
- **Advanced Filtering**: Search by breed, age category, vaccination status
- **Health Monitoring**: Comprehensive health check endpoints

## 📋 Prerequisites

- Ruby 3.3+
- Rails 7.2+
- PostgreSQL 14+
- Redis 6+
- Bundler

## 🛠️ Installation

### 1. Install System Dependencies

**Ubuntu/Debian:**

```bash
# Update packages
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib libpq-dev

# Install Redis
sudo apt install redis-server

# Start services
sudo systemctl start postgresql
sudo systemctl start redis-server
```

**macOS:**

```bash
# Using Homebrew
brew install postgresql@14 redis
brew services start postgresql@14
brew services start redis
```

### 2. Clone and Setup the Project

```bash
# Clone the repository
git clone <repository-url>
cd pet_test

# Install Ruby dependencies
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed
```

### 3. Configure Environment Variables

```bash
# Copy the example file
cp .env.example .env

# Edit .env with your settings
# For development, the defaults should work
```

## 🚀 Running the Application

### Option 1: Using Procfile with a Process Manager (Recommended)

First, install a process manager:

```bash
# Option A: Foreman
gem install foreman

# Option B: Overmind (faster, with tmux support)
brew install overmind  # macOS
# or download from https://github.com/DarthSim/overmind/releases

# Option C: Hivemind
brew install hivemind  # macOS
```

Then run all services:

```bash
# With Foreman
foreman start

# With Overmind
overmind start

# With Hivemind
hivemind
```

This will start all services defined in the Procfile:

- Redis server
- Sidekiq worker for background jobs
- Rails server on http://localhost:3000

### Option 2: Manual Start (Without Procfile)

If you prefer not to use a Procfile, run each service in a separate terminal:

```bash
# Terminal 1: Start Redis (if not already running as a service)
redis-server

# Terminal 2: Start Sidekiq worker
bundle exec sidekiq -C config/sidekiq.yml

# Terminal 3: Start Rails server
rails server -p 3000
```

**Note:** Make sure Redis is installed and running before starting Sidekiq and Rails.

This will start:

- PostgreSQL database
- Redis server
- Rails API on http://localhost:3000
- Sidekiq worker
- Automatic database setup

## 📚 API Documentation

### Base URL

```
http://localhost:3000/api/v1
```

### Endpoints

#### Pets

- `GET /pets` - List all pets (paginated, filterable)
- `POST /pets` - Create a pet
- `GET /pets/:id` - Get pet details
- `PATCH /pets/:id` - Update pet
- `DELETE /pets/:id` - Delete pet

#### Vaccination Records

- `GET /pets/:pet_id/vaccination_records` - List vaccinations
- `POST /pets/:pet_id/vaccination_records` - Create vaccination
- `GET /pets/:pet_id/vaccination_records/:id` - Get vaccination details
- `PATCH /pets/:pet_id/vaccination_records/:id` - Update vaccination
- `DELETE /pets/:pet_id/vaccination_records/:id` - Delete vaccination
- `POST /pets/:pet_id/vaccination_records/:id/mark_as_expired` - Mark as expired

#### Health Checks

- `GET /health` - Basic health check
- `GET /health/detailed` - Detailed health check with metrics

## 🔧 Configuration

### Sidekiq Web Interface

Access the Sidekiq dashboard at: http://localhost:3000/sidekiq

- View job queues and statistics
- Monitor cron jobs
- Retry failed jobs

### Background Jobs

The application includes:

- **VaccinationExpirationJob**: Sends notifications when vaccinations expire
- **CheckExpiredVaccinationsJob**: Daily job (9am) to check and mark expired vaccinations

## 🧪 Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/pet_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

## 📊 Monitoring

- **Health Endpoint**: `/api/v1/health` for uptime monitoring
- **Sidekiq Web**: `/sidekiq` for job monitoring (auth required in production)
- **Logs**: Check `log/development.log` or `log/production.log`

## 🔒 Security

- CORS configured for API access
- SSL forced in production
- Sidekiq Web protected with basic auth in production
- API rate limiting ready (configure in nginx/cloudflare)

## 📦 Postman Collection

Import `Pet_Vaccination_API.postman_collection.json` for ready-to-use API requests.

## To Go Further

- Add Docker
- Add CI/CD
- Add security layers
- Add tracking / monitoring
- Add alerting
- Add cache
