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