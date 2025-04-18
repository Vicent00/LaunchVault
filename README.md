# Token Presale Smart Contract

A robust and secure smart contract implementation for conducting token presales on the Arbitrum network, supporting multiple payment methods (ETH, USDT, USDC) with phased pricing structures.

## Features

- **Multiple Payment Options**
  - ETH (Native cryptocurrency)
  - USDT
  - USDC

- **Multi-Phase System**
  - Configurable phases with different prices
  - Automatic phase transitions based on sales volume and time
  - Individual phase caps

- **Security Features**
  - Blacklist functionality for suspicious addresses
  - Emergency withdrawal mechanisms
  - Reentrancy protection
  - OpenZeppelin's secure token standards
  - Owner-only administrative functions

- **Price Oracle Integration**
  - Chainlink price feed integration for accurate ETH/USD conversion

- **Token Distribution**
  - Automated token distribution system
  - Claim mechanism after presale ends
  - Maximum selling amount cap

## Smart Contracts

### Main Contracts
- `Presale.sol`: Main presale contract handling token sales and distributions
- `IAgregator.sol`: Interface for Chainlink price feed integration

### Dependencies
- OpenZeppelin Contracts
  - ERC20
  - Ownable
  - ReentrancyGuard
  - SafeERC20

## Technical Specifications

### Presale Phases
The presale consists of three phases, each with:
- Token allocation
- Token price
- Time duration

### Supported Networks
- Arbitrum Mainnet

### Prerequisites
- Foundry
- Solidity ^0.8.26

## Setup and Deployment

1. Clone the repository
```bash
git clone <repository-url>
```

2. Install dependencies
```bash
forge install
```

3. Run tests
```bash
forge test
```

4. Deploy contract (example for Arbitrum mainnet)
```bash
forge script script/Deploy.s.sol --rpc-url <your-rpc-url> --private-key <your-private-key>
```

## Contract Parameters

When deploying the presale contract, you'll need to provide:

- USDT contract address
- USDC contract address
- Sale token address
- Chainlink ETH/USD price feed address
- Phase configurations (amount, price, duration)
- Maximum selling amount
- Funds receiver address
- Start and end times

## Testing

The project includes comprehensive tests covering:
- Initial setup verification
- Token purchases with USDT
- Token purchases with ETH
- Phase transitions
- Blacklist functionality
- Token claiming
- Emergency withdrawals

Run the tests using:
```bash
forge test
```

## Security Considerations

- Contract includes emergency withdrawal functions for both ERC20 tokens and ETH
- Blacklist functionality to prevent malicious actors
- ReentrancyGuard implementation to prevent reentrancy attacks
- SafeERC20 usage for secure token transfers
- Owner-only access for critical functions

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
