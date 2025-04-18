<h1 align="center" style="text-align: center;">🚀 Launch Vault Presale</h1>

<div align="center">
  <img src="https://img.shields.io/badge/Solidity-0.8.26-blue?style=for-the-badge&logo=solidity&logoColor=white" alt="Solidity">
  <img src="https://img.shields.io/badge/Foundry-FFDB1C?style=for-the-badge&logo=ethereum&logoColor=black" alt="Foundry">
  <img src="https://img.shields.io/badge/Arbitrum-28A0F0?style=for-the-badge&logo=arbitrum&logoColor=white" alt="Arbitrum">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License">
</div>

<br>

<div align="center">
  <img src="structure.png" alt="Project Structure" width="600">
  <p><em>Visual representation of the project's structure and components</em></p>
</div>


## 📋 Table of Contents

- [✨ Features](#features)
- [🏗 Architecture](#architecture)
- [🚀 Getting Started](#getting-started)
- [💻 Usage](#usage)
- [🧪 Testing](#testing)
- [🔒 Security](#security)
- [🤝 Contributing](#contributing)
- [📄 License](#license)

## ✨ Features

### 💰 Payment System
| Method | Description | Price |
|--------|-------------|--------|
| ETH | Direct Ethereum payment | Variable |
| USDT | Tether payment | Fixed |
| USDC | USD Coin payment | Fixed |

### 📊 Presale Phases
```mermaid
graph TD
    A[Phase 1] -->|Completed| B[Phase 2]
    B -->|Completed| C[Phase 3]
    A -->|Time| B
    B -->|Time| C
```

### 🔒 Security Features
- ✅ Reentrancy protection
- ✅ Address blacklisting
- ✅ Emergency functions
- ✅ Role-based access control

## 🏗 Architecture

### Project Structure
```mermaid

graph TD
    subgraph "Project Structure"
        A[LauchVault] --> B[src]
        A --> C[test]
        A --> D[lib]
        A --> E[script]
        
        B --> F[Presale.sol]
        B --> G[interfaces]
        G --> H[IAgregator.sol]
        
        C --> I[Presale.t.sol]
        
        D --> J[openzeppelin-contracts]
        
    end
```

### Flow Diagram
```mermaid
sequenceDiagram
    participant User
    participant Contract
    participant Oracle
    User->>Contract: Buy tokens
    Contract->>Oracle: Query price
    Oracle-->>Contract: Return price
    Contract->>User: Deliver tokens
```

### Flow Transactions
```mermaid
sequenceDiagram
    participant User
    participant Presale
    participant Oracle
    participant Token
    
    User->>Presale: Buy Tokens (ETH/USDT/USDC)
    Presale->>Oracle: Get ETH Price
    Oracle-->>Presale: Return Price
    Presale->>Presale: Calculate Token Amount
    Presale->>Presale: Update Phase if Needed
    Presale->>Token: Transfer Payment
    Presale->>Presale: Update User Balance
    Presale-->>User: Confirm Purchase
    
    Note over User,Presale: After Presale Ends
    User->>Presale: Claim Tokens
    Presale->>Presale: Verify Balance
    Presale->>Token: Transfer Tokens
    Token-->>User: Receive Tokens
```

## 🚀 Getting Started

### Prerequisites
- [Git](https://git-scm.com/)
- [Foundry](https://getfoundry.sh/)
- [Node.js](https://nodejs.org/)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/presale-contract.git
cd presale-contract
```

2. Install dependencies
```bash
forge install
```

3. Set up environment
```bash
cp .env.example .env
# Edit .env with your configuration
```

## 💻 Usage


### Contract Interaction

#### For Users
```solidity
// Buy tokens with ETH
function buyTokensEth() external payable

// Buy tokens with USDT/USDC
function buyTokensERC20(address tokenUsedToBuy_, uint256 amount_) external

// Claim purchased tokens
function claimTokens() external
```

#### For Administrators
```solidity
// Blacklist management
function addToBlacklist(address user_) external
function removeFromBlacklist(address user_) external

// Emergency functions
function emergencyWithdrawERC20(address tokenAddress_, uint256 amount_) external
function emergencyWithdrawEth() external
```

## �� Code Documentation

### Contract Structure
```mermaid
graph TD
    subgraph "Presale.sol Documentation"
        A[Contract Overview] --> B[State Variables]
        A --> C[Events]
        A --> D[Functions]
        
        B --> B1[Token Addresses]
        B --> B2[Phase Configuration]
        B --> B3[Security Variables]
        
        C --> C1[TokensPurchased]
        C --> C2[TokensBoughtETH]
        C --> C3[PhaseUpdated]
        
        D --> D1[Constructor]
        D --> D2[Buy Functions]
        D --> D3[Admin Functions]
        D --> D4[Security Functions]
    end
```

### Key Documentation Elements
```mermaid
mindmap
  root((Presale Contract))
    (State Variables)
      (Token Addresses)
      (Phase Configuration)
      (Security Variables)
    (Events)
      (Purchase Events)
      (Phase Events)
      (Security Events)
    (Functions)
      (User Functions)
      (Admin Functions)
      (Security Functions)
```

### Documentation Flow
```mermaid
flowchart LR
    subgraph "Documentation Types"
        A[Contract Overview] --> B[Function Documentation]
        B --> C[Parameter Documentation]
        C --> D[Event Documentation]
    end
    
    subgraph "Documentation Elements"
        E[State Variables] --> F[Function Parameters]
        F --> G[Return Values]
        G --> H[Events Emitted]
    end
```

### Documentation Coverage
```mermaid
pie title Documentation Coverage
    "State Variables" : 30
    "Functions" : 40
    "Events" : 20
    "Constructor" : 10
```

### Function Documentation Structure
```mermaid
graph LR
    A[Function Name] --> B[Parameters]
    B --> C[Return Values]
    C --> D[Events]
    D --> E[Requirements]
```

### Security Documentation
```mermaid
graph TD
    A[Security Features] --> B[Access Control]
    A --> C[Reentrancy Protection]
    A --> D[Emergency Functions]
    
    B --> B1[Owner Only]
    B --> B2[Blacklist]
    
    C --> C1[NonReentrant]
    C --> C2[Safe Transfers]
    
    D --> D1[Withdraw Functions]
    D --> D2[Pause Functions]
```


## 🧪 Testing

### Running Tests
```bash
# Run all tests
forge test

# Run specific test
forge test --match-path test/Presale.t.sol

# Run with verbosity
forge test -vvv
```

### Test Coverage
```bash
forge coverage
```

## 🔒 Security

### Audit Status
| Type | Status |
|------|--------|
| Static Analysis | ✅ Completed |
| Unit Tests | ✅ Completed |
| External Audit | ⏳ Pending |

### Security Measures
- 🔒 Reentrancy protection
- 🔑 Access control
- 🧮 Safe math operations
- 🚨 Emergency functions
- ⚠️ Blacklist capability

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
```bash
git checkout -b feature/AmazingFeature
```
3. Commit your changes
```bash
git commit -m 'Add some AmazingFeature'
```
4. Push to the branch
```bash
git push origin feature/AmazingFeature
```
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Built with ❤️ by Your Name</sub>
</div>



