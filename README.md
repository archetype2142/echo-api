# Echo API

A flexible mock API service that allows you to create and manage mock endpoints dynamically.

## Features

- **Dynamic Endpoint Creation**: Create mock endpoints on the fly with custom responses
- **HTTP Method Support**: Supports GET, POST, PUT, PATCH, DELETE methods
- **Custom Response Configuration**: Define status codes, headers, and response bodies
- **JSON:API Compliant**: All endpoints follow the JSON:API specification
- **Token Authentication**: Secure your endpoints with token-based authentication

## Getting Started

### Prerequisites

- Ruby 3.1.0
- Rails 7.0+
- PostgreSQL

### Installation

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Set up the database:
   ```bash
   rails db:create db:migrate
   ```

3. Set your API token:
   ```bash
   echo "API_TOKEN=your-secret-token" > .env
   ```

### Running the Server

```bash
rails server
```

## Usage

### Creating an Endpoint

```bash
curl -X POST http://localhost:3000/endpoints \
  -H "Authorization: Token your-token" \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "endpoints",
      "attributes": {
        "verb": "GET",
        "path": "/hello",
        "response": {
          "code": 200,
          "headers": {
            "Content-Type": "application/json"
          },
          "body": {
            "message": "Hello, World!"
          }
        }
      }
    }
  }'
```

### Using the Mock Endpoint

```bash
curl http://localhost:3000/hello \
  -H "Authorization: Token your-token"
```

## Security

- All endpoints require token authentication
- Uses `secure_compare` for timing-attack-safe token comparison
- Enforces strict content type validation for JSON:API compliance

## Development

### Running Tests

```bash
bundle exec rspec
```

## API Documentation

### Endpoint Management API

All management endpoints require:
- `Authorization: Token <token>` header
- `Content-Type: application/vnd.api+json` for POST/PUT/PATCH requests

#### Available Endpoints

- `GET /endpoints` - List all endpoints
- `POST /endpoints` - Create a new endpoint
- `GET /endpoints/:id` - Get endpoint details
- `PATCH /endpoints/:id` - Update an endpoint
- `DELETE /endpoints/:id` - Delete an endpoint
