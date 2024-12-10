# CryptoStream

## Project Overview

CryptoStream is a real-time cryptocurrency market data streaming application built using the Phoenix framework. It provides users with up-to-date market information and trading capabilities.

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

4. Start the server:
   ```bash
   mix phx.server
   ```

## Usage

Once the server is running, access the application at [localhost:4000](http://localhost:4000) to view real-time cryptocurrency data and perform trading actions.

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

![Screenshot 1](instructions/Screenshot%202024-12-10%20at%206.03.49%20PM.png)
![Screenshot 2](instructions/Screenshot%202024-12-10%20at%206.03.54%20PM.png)
![Screenshot 3](instructions/Screenshot%202024-12-10%20at%206.04.03%20PM.png)
![Screenshot 4](instructions/Screenshot%202024-12-10%20at%206.04.12%20PM.png)
