# Yoyo Web3 App: NFT Auction Platform for Yoga Enthusiasts

This project consists of a complete NFT auction system built on the Ethereum blockchain. It includes two main smart contracts: **YoyoAuction** for managing English and Dutch auctions, and **YoyoNft** for minting and managing ERC-721 tokens. The project was developed, tested, and deployed using the Foundry development environment.

## Index

1. [Description](#1-description)
2. [Contract Address on Sepolia](#2-contract-address-on-sepolia)
3. [Project Structure](#3-project-structure)
4. [Clone and Configuration](#4-clone-and-configuration)
5. [Technical Choices](#5-technical-choices)
6. [Contributing](#6-contributing)
7. [License](#7-license)
8. [Contacts](#8-contacts)

## 1. Description

**Yoyo Web3 App** is a decentralized NFT auction platform developed and deployed on the Ethereum Sepolia testnet as part of the "Ethereum Advanced" project. The project aims to create an engaging way for yoga enthusiasts to collect unique NFTs through automated auction mechanisms.

The platform consists of two interconnected smart contracts:

### YoyoAuction Contract

The **YoyoAuction** contract manages the complete auction lifecycle with support for both English and Dutch auction formats:

#### Key Features:

-   **Dual Auction Types**:

    -   **English Auctions**: Traditional ascending price auctions where bidders compete to place the highest bid
    -   **Dutch Auctions**: Descending price auctions that start high and drop at regular intervals until a bidder accepts the current price

-   **Automated Lifecycle Management**:

    -   Powered by Chainlink Automation (Keepers) for automatic auction closure and restart
    -   Grace period mechanism to allow manual intervention if Chainlink Automation is down
    -   24-hour auction duration with configurable parameters

-   **Robust Error Handling**:

    -   Fallback minting mechanism when direct mint to winner fails
    -   Failed refund tracking for previous bidders
    -   Manual claim functions for both NFTs and refunds

-   **Security Features**:
    -   ReentrancyGuard protection on all state-changing functions
    -   Owner-only administrative functions
    -   Validation of bid amounts and auction states

#### Auction Flow:

1. **Opening**: Owner opens an auction with a specific NFT tokenId and auction type
2. **Bidding**:
    - English: Users place incrementing bids (minimum 2.5% increase)
    - Dutch: First bidder at or above current price wins immediately
3. **Closure**: Automatic closure via Chainlink Automation or manual intervention after grace period
4. **Minting**: NFT automatically minted to winner, with fallback to contract if direct mint fails
5. **Claiming**: Winners can manually claim NFTs if automatic minting failed

### YoyoNft Contract

The **YoyoNft** contract manages the ERC-721 NFT collection with auction-specific functionality:

#### Key Features:

-   **Limited Supply**: Maximum 20 NFTs in the collection
-   **Auction Integration**: Only the auction contract can mint NFTs
-   **Dynamic Pricing**: Mint price adjustable by auction contract to match auction dynamics
-   **Safe Transfers**: Implements ERC721 safe transfer mechanisms
-   **Metadata Management**: Base URI configuration for token metadata

#### Constructor Parameters:

The constructor uses a `ConstructorParams` struct for modular deployment across different chains:

-   `baseURI`: Base URI for token metadata
-   `auctionContract`: Address of the authorized auction contract
-   `basicMintPrice`: Initial mint price in wei

#### Core Functions:

-   **mintNft()**: Called by auction contract to mint NFTs to winners
-   **transferNft()**: Allows owners to transfer their NFTs
-   **withdraw()**: Owner-only function to withdraw collected fees
-   **deposit()**: Owner-only function to add funds to contract
-   **setBasicMintPrice()**: Auction-only function to update mint price

### Read-Only Functions (Getters)

Both contracts provide comprehensive view functions to query state:

**YoyoAuction Getters:**

-   `getCurrentAuction()`: Returns complete data of latest auction
-   `getAuctionFromAuctionId(uint256)`: Retrieves auction by ID
-   `getCurrentAuctionPrice()`: Calculates current price for ongoing auction
-   `getElegibilityForClaimingNft(uint256, address)`: Checks if address can claim NFT
-   `getFailedRefundAmount(address)`: Returns unclaimed refund balance

**YoyoNft Getters:**

-   `tokenURI(uint256)`: Returns metadata URI for token
-   `getTotalMinted()`: Returns number of minted NFTs
-   `getBasicMintPrice()`: Current mint price
-   `getIfTokenIdIsMintable(uint256)`: Checks if token can be minted
-   `getOwnerFromTokenId(uint256)`: Returns owner of token
-   `getAccountBalance(address)`: Returns NFT balance of address

## 2. Contract Address on Sepolia

### YoyoAuction Contract

**Address**: `0x51eaAa1a6b1cF652B58da67cB32a0f7999263619`
**Etherscan Link**: `https://sepolia.etherscan.io/address/0x51eaAa1a6b1cF652B58da67cB32a0f7999263619`

### YoyoNft Contract

**Address**: `0x81a9B713128A4DF3349D9Bc363CEE1D77accDCA3`
**Etherscan Link**: `https://sepolia.etherscan.io/address/0x81a9B713128A4DF3349D9Bc363CEE1D77accDCA3`

### How to Interact with the Contracts

You can interact with the deployed smart contracts via Etherscan or through the project's frontend interface.

**Requirements:**

-   A wallet configured for Sepolia testnet (e.g., MetaMask)
-   Some Sepolia ETH
-   The deployed contract addresses

**To participate in an auction:**

1. Go to the YoyoAuction contract on Etherscan
2. Open the "Read Contract" section to view current auction details
3. Connect your wallet in the "Write Contract" section
4. Call `placeBidOnAuction(uint256 auctionId)` with appropriate ETH value:
    - For English auctions: Send at least `currentPrice + minimumBidChangeAmount`
    - For Dutch auctions: Send at least the current price

**To claim an NFT (if auto-mint failed):**

1. Call `claimNftForWinner(uint256 auctionId)` on the YoyoAuction contract
2. Pay the required mint price if the NFT wasn't already minted

**To claim a failed refund:**

1. Check your refund balance with `getFailedRefundAmount(address)`
2. Call `claimFailedRefunds()` to withdraw

## 3. Project Structure

```
foundry/
├── script/
│   ├── DeployYoyoAuctionAndYoyoNft.s.sol
│   └── HelperConfig.sol
├── src/
│   ├── YoyoAuction/
│   │   ├── YoyoAuction.sol
│   │   ├── YoyoDutchAuctionLibrary.sol
│   │   ├── YoyoAuctionEvents.sol
│   │   └── YoyoAuctionErrors.sol
│   ├── YoyoNft/
│   │   ├── YoyoNft.sol
│   │   ├── IYoyoNft.sol
│   │   ├── YoyoNftEvents.sol
│   │   └── YoyoNftErrors.sol
│   └── YoyoTypes.sol
├── test/
│   ├── YoyoAuctionTest/
│   │   ├── YoyoAuction.Base.t.sol
│   │   ├── YoyoAuction.OpenNewAuction.t.sol
│   │   ├── YoyoAuction.PlaceBid.t.sol
│   │   ├── YoyoAuction.CloseAuction.t.sol
│   │   ├── YoyoAuction.PerformUpkeep.t.sol
│   │   └── YoyoDutchAuctionLibrary.t.sol
│   ├── YoyoNft.t.sol
│   ├── YoyoDeployAndConfigScripts.t.sol
│   └── Mocks/
│       ├── EthAndNftRefuseMock.sol
│       └── YoyoNftFailingMintMock.sol
├── Makefile
├── foundry.toml
└── .env
```

### Key Files

#### DeployYoyoAuctionAndYoyoNft.s.sol

This script orchestrates the deployment of both contracts. It:

-   Deploys the YoyoAuction contract with the Chainlink Automation registry
-   Deploys the YoyoNft contract with auction contract address and configuration
-   Links both contracts by calling `setNftContract()` on the auction
-   Works with `HelperConfig` to adapt deployment across networks

#### HelperConfig.sol

Network-specific configuration handler that:

-   Detects current chain ID (Mainnet, Sepolia, or Anvil)
-   Provides appropriate constructor parameters for each network
-   Manages Chainlink Automation registry addresses
-   Configures base URIs and mint prices per network
-   Creates mock Keepers for local testing

#### YoyoAuction.sol

The main auction management contract with:

-   Dual auction type support (English and Dutch)
-   Chainlink Automation integration for lifecycle management
-   Comprehensive error handling and fallback mechanisms
-   Secure bid processing with ReentrancyGuard
-   Gas-efficient library usage for Dutch auction calculations

#### YoyoDutchAuctionLibrary.sol

A library providing utility functions for Dutch auction price calculations:

-   `currentPriceFromTimeRangeCalculator()`: Computes current price based on elapsed time
-   `dropAmountFromPricesAndIntervalsCalculator()`: Calculates price drop per interval
-   `startPriceFromReserveAndMultiplierCalculator()`: Determines auction start price

#### YoyoNft.sol

The NFT collection contract with:

-   ERC-721 standard compliance via OpenZeppelin
-   Auction-only minting restriction
-   Dynamic mint price adjustment
-   Safe transfer mechanisms
-   Comprehensive getter functions

#### Test Contracts

-   **Base.t.sol**: Common setup and helper functions for all auction tests
-   **OpenNewAuction.t.sol**: Tests for auction creation and initialization
-   **PlaceBid.t.sol**: Tests for bid placement in both auction types
-   **CloseAuction.t.sol**: Tests for auction closure, minting, and fallback scenarios
-   **PerformUpkeep.t.sol**: Tests for Chainlink Automation integration
-   **YoyoDutchAuctionLibrary.t.sol**: Unit tests for library functions
-   **YoyoNft.t.sol**: Complete NFT contract functionality tests

#### Mock Contracts

The project includes sophisticated mock contracts to test edge cases and failure scenarios that are difficult or impossible to simulate with real contracts.

##### EthAndNftRefuseMock.sol

A comprehensive mock contract designed to simulate various failure modes when receiving ETH or NFTs. This is crucial for testing the auction contract's fallback mechanisms.

**Purpose**:

-   Tests failed refund scenarios when previous bidders cannot receive ETH
-   Tests failed NFT transfer scenarios when winners cannot receive NFTs
-   Validates that the auction contract properly handles and tracks failures

**Key Features**:

1. **Configurable ETH Reception**:

    - `setCanReceiveEth(bool)`: Controls whether the contract accepts ETH transfers
    - When set to `false`, both `receive()` and `fallback()` functions revert
    - Used to test the auction's failed refund tracking mechanism

2. **Configurable NFT Reception**:

    - `setCanReceiveNft(bool)`: Controls whether the contract accepts NFT transfers
    - When set to `false`, `onERC721Received()` returns invalid selector
    - Used to test fallback minting when direct mint to winner fails

3. **Error Type Simulation**:

    - `setThrowPanicError(bool)`: Triggers panic errors (division by zero)
    - `setCauseOutOfGas(bool)`: Enters infinite loop to consume all gas
    - Tests different catch blocks in the auction contract's try-catch logic

4. **Auction Interaction Methods**:

    - `placeBid(uint256 auctionId)`: Allows the mock to participate in auctions
    - `claimRefund()`: Tests claiming failed refunds from auction
    - `claimNftFromAuction(uint256)`: Tests claiming NFTs from auction

5. **NFT Contract Interaction Methods**:
    - `depositOnNftContract()`: Tests depositing ETH to NFT contract
    - `withdrawFromNftContract()`: Tests withdrawing from NFT contract (owner-only)

**Usage Example in Tests**:

```solidity
// Setup: Create mock that rejects ETH
EthAndNftRefuseMock bidder = new EthAndNftRefuseMock(address(auction), address(nft));
bidder.setCanReceiveEth(false); // Mock will reject ETH refunds

// Test scenario: Place two bids to trigger refund
bidder.placeBid{value: 1 ether}(auctionId);
vm.prank(otherUser);
auction.placeBidOnAuction{value: 2 ether}(auctionId);

// Verify: Refund should have failed and been tracked
uint256 failedRefund = auction.getFailedRefundAmount(address(bidder));
assertGt(failedRefund, 0);

// Recovery: Mock can later claim the failed refund
bidder.setCanReceiveEth(true);
bidder.claimRefund();
```

**Test Coverage**:

-   Failed refunds to contracts that reject ETH
-   Failed NFT mints to contracts that reject NFTs
-   Panic errors during NFT reception
-   Out-of-gas scenarios during NFT reception
-   Manual claim mechanisms for both ETH and NFTs

##### YoyoNftFailingMintMock.sol

A specialized mock of the YoyoNft contract that can simulate various mint failure scenarios on demand.

**Purpose**:

-   Tests the auction contract's fallback minting logic
-   Validates error message propagation through try-catch blocks
-   Ensures auction can handle both standard reverts and panic errors during minting

**Key Features**:

1. **Configurable Revert with Message**:

    - `setShouldFailMint(bool, string reason)`: Makes `mintNft()` revert with custom message
    - Caught by `catch Error(string memory reason)` block in auction
    - Used to test error message logging in events

2. **Configurable Panic Error**:

    - `setShouldPanic(bool)`: Makes `mintNft()` trigger panic via invalid opcode
    - Caught by generic `catch (bytes memory)` block in auction
    - Used to test low-level error handling

3. **State Variables for Configuration**:

    - `bool shouldFailMint`: Flag to enable/disable revert
    - `bool shouldPanic`: Flag to enable/disable panic
    - `string failureReason`: Custom error message for standard reverts

4. **Mint Behavior**:
    - If `shouldPanic` is true → Executes invalid opcode (assembly `invalid()`)
    - Else if `shouldFailMint` is true → Reverts with `failureReason` message
    - Else → Performs normal mint operation

**Usage Example in Tests**:

```solidity
// Setup: Deploy mock NFT contract
YoyoNftFailingMintMock nftMock = new YoyoNftFailingMintMock(params);
auction.setNftContract(address(nftMock));

// Test 1: Standard revert with error message
nftMock.setShouldFailMint(true, "Mint temporarily disabled");
nftMock.setShouldPanic(false);

// Place bid and close auction
auction.placeBidOnAuction{value: price}(auctionId);
vm.warp(block.timestamp + AUCTION_DURATION + 1);
auction.performUpkeep(performData);

// Verify: Auction emitted MintFailed event with error message
// and attempted fallback mint to contract

// Test 2: Panic error (no error message)
nftMock.setShouldFailMint(false, "");
nftMock.setShouldPanic(true);

// Open new auction and bid
uint256 auctionId2 = auction.openNewAuction(tokenId2, AuctionType.ENGLISH);
auction.placeBidOnAuction{value: price}(auctionId2);

// Close auction
vm.warp(block.timestamp + AUCTION_DURATION + 1);
auction.performUpkeep(performData2);

// Verify: Auction caught panic and emitted event with "Low-level mint failure"

// Test 3: Successful mint after resetting flags
nftMock.setShouldFailMint(false, "");
nftMock.setShouldPanic(false);

// Now mint should succeed normally
```

**Test Coverage**:

-   Standard Error() revert with custom message
-   Panic errors without error messages
-   Fallback minting to auction contract
-   Winner eligibility tracking for manual claims
-   Event emission for different failure types
-   Successful mint after toggling flags off

**Implementation Details**:

The mock uses a priority system in `mintNft()`:

1. First checks `shouldPanic` → triggers invalid opcode if true
2. Then checks `shouldFailMint` → reverts with message if true
3. Otherwise proceeds with normal mint validation and execution

This allows precise control over which failure mode to test, and ensures that panic errors take precedence over standard reverts (since panic would prevent reaching the revert check).

**Why These Mocks Are Essential**:

1. **Real-World Simulation**: Smart contracts can fail to receive ETH or NFTs for various reasons:

    - Contract without receive/fallback functions
    - Contract that explicitly rejects transfers
    - Out-of-gas during transfer
    - Reentrancy guard active

2. **Edge Case Coverage**: These scenarios are rare but critical to handle correctly:

    - If not handled, funds or NFTs could be permanently locked
    - The auction must track failures and provide recovery mechanisms

3. **Error Handling Verification**: Tests that the auction contract:

    - Properly catches different error types
    - Logs appropriate events for off-chain monitoring
    - Maintains state consistency after failures
    - Provides manual recovery options

4. **Gas Estimation**: Helps estimate worst-case gas costs when multiple fallback attempts occur

5. **Security Assurance**: Proves that the auction cannot be griefed by malicious contracts that intentionally fail transfers

## 4. Clone and Configuration

### 1. Clone the repository

```bash
git clone https://github.com/eliab256/S2I-Final-Project-Yoyo-Web3App.git
cd S2I-Final-Project-Yoyo-Web3App/foundry
```

### 2. Install Foundry

If you haven't installed Foundry yet:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 3. Install dependencies

```bash
forge install
```

### 4. Create and configure .env file

Create a `.env` file in the `foundry/` directory:

```bash
# RPC URLs
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_INFURA_KEY

# Private Key (NEVER commit this!)
PRIVATE_KEY=your_private_key_here

# Etherscan API Key
ETHERSCAN_API_KEY=your_etherscan_api_key

# NFT Metadata
BASE_URI=ipfs://YOUR_IPFS_CID
```

### 5. Build the project

```bash
forge build
```

### 6. Run tests

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test file
forge test --match-path test/YoyoAuctionTest/YoyoAuction.PlaceBid.t.sol

# Run with gas report
forge test --gas-report

# Generate coverage report
forge coverage
```

### 7. Deploy to Sepolia

```bash
# Using Makefile
make deploy-sepolia

# Or directly with forge
forge script script/DeployYoyoAuctionAndYoyoNft.s.sol:DeployYoyoAuctionAndYoyoNft \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY
```

### 8. Verify contracts (if not auto-verified)

```bash
forge verify-contract \
    --chain-id 11155111 \
    --constructor-args $(cast abi-encode "constructor(address)" "REGISTRY_ADDRESS") \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    CONTRACT_ADDRESS \
    src/YoyoAuction/YoyoAuction.sol:YoyoAuction
    --etherscan-api-key $ETHERSCAN_API_KEY \
    CONTRACT_ADDRESS \
    src/YoyoAuction/YoyoAuction.sol:YoyoAuction
```

## 5. Technical Choices

### Languages

-   **Solidity ^0.8.0**: For smart contract development with latest security features and gas optimizations

### Development Tools

-   **Foundry**: Blazing fast, portable toolkit for Ethereum development written in Rust
    -   **Forge**: Testing framework with advanced features (fuzz testing, invariant testing)
    -   **Cast**: CLI tool for blockchain interactions
    -   **Anvil**: Local Ethereum node for development
    -   **Chisel**: Solidity REPL for rapid prototyping

### Libraries and Dependencies

#### OpenZeppelin Contracts

Industry-standard, audited smart contract library for:

-   **ERC721**: NFT standard implementation in YoyoNft
-   **Ownable**: Access control for administrative functions
-   **ReentrancyGuard**: Protection against reentrancy attacks in auction contract
-   **IERC721Receiver**: Safe NFT transfer interface

```bash
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

#### Chainlink

Decentralized oracle network integration:

-   **Chainlink Automation (Keepers)**: Automated auction lifecycle management
    -   Automatic auction closure when time expires
    -   Automatic auction restart when no bids placed
    -   Grace period mechanism for manual intervention
-   **AutomationCompatibleInterface**: Standard interface for Keeper-compatible contracts

```bash
forge install smartcontractkit/chainlink-brownie-contracts@1.2.0 --no-commit
```

#### Foundry DevOps

Automation tools for deployment and contract management:

-   Retrieves most recent deployment addresses from broadcast folder
-   Eliminates need for hardcoded addresses in scripts
-   Simplifies multi-chain deployment workflows

```bash
forge install Cyfrin/foundry-devops --no-commit
```

### Architecture Decisions

#### 1. Dual Auction Type Support

**Why**: Provides flexibility for different NFT distribution strategies

-   **English auctions**: Maximize revenue when demand is uncertain
-   **Dutch auctions**: Guarantee quick sales with price discovery

**Implementation**:

-   Shared base logic with type-specific functions
-   Library-based Dutch auction calculations for gas efficiency
-   Enum-based type identification

#### 2. Chainlink Automation Integration

**Why**: Ensures reliable, trustless auction lifecycle management without manual intervention

**Benefits**:

-   Auctions close automatically at expiration
-   No reliance on external bots or centralized servers
-   Transparent, verifiable execution

**Fallback**: Grace period allows manual execution if Chainlink is temporarily down

#### 3. Comprehensive Error Handling

**Why**: NFT minting and ETH transfers can fail in various scenarios

**Mechanisms**:

-   Failed mint to winner → Mint to contract, allow manual claim
-   Failed refund to bidder → Track in mapping, allow manual claim
-   Clear error messages via custom errors (gas efficient)
-   Event emission for all failure scenarios

#### 4. Modular Contract Design

**Why**: Separation of concerns improves maintainability and testability

**Structure**:

-   Separate Events and Errors files for clarity
-   Library for complex calculations (Dutch auctions)
-   Interface for inter-contract communication
-   Shared types in YoyoTypes.sol

#### 5. Gas Optimization Strategies

**Techniques Used**:

-   Custom errors instead of require strings
-   Immutable variables for deployment-time constants
-   Unchecked arithmetic where overflow is impossible
-   Library functions for complex calculations
-   Efficient storage packing

#### 6. Comprehensive Testing

**Test Coverage**:

-   Unit tests for individual functions
-   Integration tests for contract interactions
-   Mock contracts for failure scenario testing
-   Fuzz testing for edge cases (TODO: implement)
-   Invariant testing for state consistency (TODO: implement)

**Test Structure**:

-   Base test contract with common setup
-   Separate test files per contract function group
-   Mock contracts in dedicated directory

### Security Considerations

1. **ReentrancyGuard**: All state-changing functions protected
2. **Access Control**: Owner-only and auction-only modifiers
3. **Input Validation**: Comprehensive parameter checking
4. **Pull Over Push**: Failed refunds use claim pattern
5. **Event Logging**: All critical actions emit events for transparency

## 6. Contributing

Thank you for your interest in contributing to **Yoyo Web3 App**! Every contribution is valuable and helps improve the project. There are various ways you can contribute:

-   **Bug Fixes**: If you find a bug, feel free to submit a fix
-   **Adding New Features**: Propose new auction types or NFT features
-   **Documentation**: Help improve code documentation and README
-   **Testing**: Add more test cases, especially fuzz and invariant tests
-   **Gas Optimization**: Suggest and implement gas-saving improvements
-   **Security Audits**: Review code for potential vulnerabilities
-   **Fork**: Adapt this project for other chains or use cases

### How to Submit a Contribution

1. **Fork the repository**: Click the "Fork" button on GitHub

2. **Clone your fork**:

    ```bash
    git clone https://github.com/YOUR_USERNAME/S2I-Final-Project-Yoyo-Web3App.git
    cd S2I-Final-Project-Yoyo-Web3App/foundry
    ```

3. **Create a new branch**:

    ```bash
    git checkout -b feature/your-feature-name
    ```

4. **Make your changes**:

    - Write clean, well-documented code
    - Follow existing code style and naming conventions
    - Add tests for new functionality
    - Update documentation as needed

5. **Test your changes**:

    ```bash
    forge test
    forge coverage
    ```

6. **Commit your changes**:

    ```bash
    git add .
    git commit -m "feat: add your feature description"
    ```

7. **Push your branch**:

    ```bash
    git push origin feature/your-feature-name
    ```

8. **Create a Pull Request**:
    - Go to the original repository on GitHub
    - Click "New Pull Request"
    - Select your branch and provide a clear description

### Contribution Guidelines

-   **Code Style**: Follow Solidity style guide and existing patterns
-   **Testing**: Ensure all tests pass and add new tests for features
-   **Documentation**: Update NatSpec comments and README as needed
-   **Commit Messages**: Use conventional commits (feat:, fix:, docs:, etc.)
-   **Gas Efficiency**: Consider gas costs in implementation decisions

### Areas Needing Contribution

-   [ ] Implement invariant tests for contract state consistency
-   [ ] Add fuzz testing for auction pricing edge cases
-   [ ] Add support for additional auction types (e.g., sealed-bid)
-   [ ] Implement pause mechanism for emergency scenarios
-   [ ] Optimize gas usage in high-frequency functions
-   [ ] Add integration with additional price feeds

## 7. License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2026 Elia Bordoni

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 8. Contacts

For more information, questions, or collaboration opportunities, you can reach me:

-   **GitHub**: [eliab256](https://github.com/eliab256)
-   **Project Repository**: [S2I-Final-Project-Yoyo-Web3App](https://github.com/eliab256/S2I-Final-Project-Yoyo-Web3App)
-   **Portfolio**: [elia-bordoni-blockchain-security-researcher.vercel.app](https://elia-bordoni-blockchain-security-researcher.vercel.app/)
-   **Email**: bordonielia96@gmail.com
-   **LinkedIn**: [Elia Bordoni](https://www.linkedin.com/in/elia-bordoni/)

---
