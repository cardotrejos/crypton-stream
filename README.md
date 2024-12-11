# CryptoStream

## Project Overview

CryptoStream is a real-time cryptocurrency market data streaming application built using the Phoenix framework. It provides users with up-to-date market information and trading capabilities.

## Technical Decisions and Architecture

### Framework and Language
- Built with Elixir/Phoenix framework (v1.7.14)
- Uses Phoenix's standard project structure
- Follows OTP principles with a supervised application

### Database and Storage
- PostgreSQL as the primary database
- Ecto as the database wrapper and schema manager
- Uses migrations for database schema management

### Authentication and Security
- Custom user authentication system
- Uses BCrypt for password hashing
- Email/password-based authentication
- Implements user accounts with email validation

### API Design
- RESTful API using OpenAPI Specification (via `open_api_spex`)
- JSON as the primary data format (using `jason` library)
- Swagger documentation available

### Domain Structure
1. **Accounts Domain**
   - User management and authentication
   - Account balance tracking
   - User profile management

2. **Trading Domain**
   - Core trading operations (buy/sell)
   - Transaction management
   - Balance validation
   - Uses Repository pattern for data access
   - Decimal precision for financial calculations

3. **Services**
   - External cryptocurrency price data integration
   - Modular price client interface
   - Support for multiple data providers

### Project Structure
- Domain-driven design approach
- Clear separation of concerns with bounded contexts
- Hexagonal architecture with ports and adapters
- Domain entities in their respective contexts

### Testing
- Separate test environment configuration
- Test support files in `test/support`
- Controller tests for API endpoints

## Installation

To set up the project locally, follow these steps:

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd crypto_stream
   ```

2. Install dependencies:
   ```bash
   mix deps.get
   ```

3. Set up the database:
   ```bash
   mix ecto.setup
   ```

4. Setup environment variables: (this was sended via email)
   ```bash
   cp .env.example .env
   ``` 

5. Start the server:
   ```bash
   mix phx.server
   ```

## Testing

Run the test suite to ensure everything is working correctly:

```bash
mix test
```

## Swagger Testing

Swagger UI can be accessed at [localhost:4000/api/swaggerui](http://localhost:4000/api/swaggerui)

1. Open the Swagger UI at [localhost:4000/api/swaggerui](http://localhost:4000/api/swaggerui)

2. Market Data endpoints can be tested by clicking on the "Try it out" button for each endpoint. (This does not require authentication)

3. Trading endpoints can be tested by clicking on the "Try it out" button for each endpoint. (This requires authentication)

4. For authentication, click on the "Authorize" button to log in with the credentials provided in the Login Request section of the "Try it out" modal. Here is an example of a successful login:
   - Go to the register endpoint and register a new user(or login with the example user)
   - Copy the token
   - Go to Autorize button and paste there

![Screenshot 2024-12-10 at 6 03 49 PM](https://github.com/user-attachments/assets/23607d38-0c67-4afb-9356-6dda703078a1)
![Screenshot 2024-12-10 at 6 03 54 PM](https://github.com/user-attachments/assets/e1bcdb2f-b31d-49db-83d8-20a065bac16a)
![Screenshot 2024-12-10 at 6 04 03 PM](https://github.com/user-attachments/assets/e0c395b7-f895-413b-8823-4ca096271f10)
![Screenshot 2024-12-10 at 6 04 12 PM](https://github.com/user-attachments/assets/e6f70273-2a6f-4cf5-b738-bb69d9218c6a)
