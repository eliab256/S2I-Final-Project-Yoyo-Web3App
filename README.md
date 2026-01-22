<br />
<div id="readme-top" align="center">
  <a href="">
    <img src="./src/assets/images/Yoyo-Logo-Scritta-Scura.png" alt="Yoyo Logo" width="100" height="100">
  </a>

<h3 align="center">YOYO</h3>

  <p align="center">
    Yoyo is a blockchain-based auction inclusive yoga platform and NFT marketplace that personalizes accessible practice paths for everyone.
    <br />
    <a href=""><strong>Visit the website</strong></a>
    <br />
  </p>
</div>

# Index

- [Index](#index)
- [1. About The Project](#1-about-the-project)
- [2. Clone and Configuration](#2-clone-and-configuration)
    - [2.1. Initialize React Project](#21-initialize-react-project)
    - [2.2. Initialize Foundry Project](#22-initialize-foundry-project)
    - [2.3. Local Environment Variables](#23-local-environment-variables)
- [3. Smart Contracts](#3-smart-contracts)
    - [3.1. Smart Contracts Details](#31-smart-contracts-details)
    - [3.2. Read From Smart Contracts](#32-read-from-smart-contracts)
    - [3.3. Write on Smart Contracts](#33-write-on-smart-contracts)
- [4. Event Indexing](#4-event-indexing)
    - [4.1. Rindexer with graphql](#41-rindexer-with-graphql)
    - [4.2. Indexed Events](#42-indexed-events)
    - [4.3. Queries](#43-queries)
- [5. Front End](#5-front-end)
    - [5.1. Providers](#51-providers)
    - [5.2. Wallet Connection](#52-wallet-connection)
    - [5.3. App Structure](#53-app-structure)
    - [5.4. Custom Hooks](#54-custom-hooks)
        - [useClaimNft:](#useclaimnft)
        - [useClaimRefund](#useclaimrefund)
        - [useCurrentAuction](#usecurrentauction)
        - [useEthereumPrice](#useethereumprice)
        - [usePlaceBid](#useplacebid)
        - [useTransferNft](#usetransfernft)
        - [useUserNFTs](#useusernfts)
    - [5.5. Redux For Global State](#55-redux-for-global-state)
- [6. Performance, Gas Optimization And Security](#6-performance-gas-optimization-and-security)
    - [6.1. Read Contract vs Read Events](#61-read-contract-vs-read-events)
    - [6.2. Use Events To Trigger Read Contract](#62-use-events-to-trigger-read-contract)
- [7. Further development](#7-further-development)
- [8. Contacts](#8-contacts)
- [9. Copyright](#9-copyright)

# 1. About The Project

# 2. Clone and Configuration

## 2.1. Initialize React Project

    1- Clone the repository

    ```
    git clone https://github.com/eliab256/Yoyo-Web3Dapp.git
    ```

    2- Navigate to the project folder

    ```
    cd Yoyo-Web3Dapp
    ```

    3- Install the dependencies

    ```
    npm install
    ```

    4- Set up your local env file (explained later)

    5- Run your local development server

    ```
    npm run dev
    ```

## 2.2. Initialize Foundry Project

    1- Once the repository has been cloned, navigate to the foundry folder
    ```
    cd foundry
    ```

    2- Install foundry
    ```
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
    ```

    3- Install dependencies
    ```
    forge install
    ```

    4- Build the project
    ```
    forge build
    ```

    5- Run the test suite
    ```
    forge test
    ```

    6- (optional) Take a look at the Makefile to try out some simplified commands

## 2.3. Local Environment Variables

# 3. Smart Contracts

## 3.1. Smart Contracts Details

For an in-depth analysis of the contracts, including deployment scripts and the test suite, please refer to the `README.md` file in the `foundry` folder. [GO TO THE CONTRACTS DOCS](https://github.com/eliab256/Yoyo-Web3Dapp/blob/main/foundry/README.md)

In the following sections, the focus will be on the interaction between the smart contracts and the front end.

In the `src/contracts` folder you can find:

- The ABI files for both contracts (`yoyoAuctionAbi.ts` and `yoyoNftAbi.ts`), which are used by the front end to interact with the deployed smart contracts.
- The `addresses.ts` file, which contains a mapping of supported chain IDs to the deployed contract addresses for both the Yoyo NFT and Yoyo Auction contracts.

**About `addresses.ts`:**
This file exports an object where each key is a chain ID (e.g., 11155111 for Sepolia) and the value is an object with the addresses of the Yoyo NFT and Yoyo Auction contracts. This allows the app to dynamically select the correct contract addresses based on the connected network.

## 3.2. Read From Smart Contracts

## 3.3. Write on Smart Contracts

# 4. Event Indexing

## 4.1. Rindexer with graphql

## 4.2. Indexed Events

## 4.3. Queries

# 5. Front End

The frontend of Yoyo Web3App is built using **React** and **TypeScript**, providing a modern, scalable, and maintainable architecture. For the graphical interface, **Tailwind CSS** is used to quickly create responsive and visually appealing components. Communication between the frontend and the blockchain is managed by the **Wagmi** library, which offers robust hooks and utilities for interacting with Ethereum smart contracts and handling wallet connections. This combination ensures a seamless user experience, secure blockchain interactions, and efficient development workflows.

## 5.1. Providers

The `Providers.tsx` component is a wrapper that sets up all the main context providers required by the application. It includes:

- **Redux Provider**: Makes the Redux store available to all components for global state management.
- **React Query Provider**: Enables efficient server state management and caching using React Query.
- **Wagmi Provider**: Supplies Ethereum wallet and blockchain connectivity using the Wagmi library and the configuration from `rainbowkitConfig`.
- **RainbowKit Provider**: Adds wallet connection UI and theming via RainbowKit.

By wrapping the app with `Providers`, all child components can access these contexts, ensuring seamless integration of state management, blockchain connectivity, and wallet UI throughout the app.

## 5.2. Wallet Connection

The wallet connection feature allows users to securely connect their Ethereum wallet (such as MetaMask, WalletConnect, or Coinbase Wallet) to the Yoyo Web3App. This is implemented using RainbowKit and Wagmi, which provide a user-friendly interface and robust connection logic.

Key points:

- Users can select and connect their preferred wallet via the RainbowKit modal.
- Once connected, the app can read the user's address, balance, and interact with smart contracts on the selected network.
- The connection status and wallet information are available throughout the app via context providers.

## 5.3. App Structure

```
root/
├── foundry/                    # Smart Contracts, script and tests
├── src/
│   ├── assets/                 # Static assets
│   │   ├── fonts/              # Fonts import
│   │   ├── images/             # Nft Images and Logos
│   │   └── styles/             # Font settings and main Css
│   │
│   ├── components/             # React components
│   │   ├── auction/            # Auction-related components
│   │   ├── layout/             # Layout components
│   │   ├── nft/                # NFT components
│   │   └── ui/                 # UI components
│   │
│   ├── contracts/              # Smart contract ABIs and addresses
│   ├── data/                   # Static data and configurations
│   ├── graphql/                # GraphQL queries and schemas
│   ├── hooks/                  # Custom React hooks
│   ├── redux/                  # Redux store, actions, and reducers
│   ├── types/                  # TypeScript type definitions
│   ├── utils/                  # Utility functions and helpers
│   ├── App.tsx                 # Main application component
│   ├── main.tsx                # Application entry point
│   ├── providers.tsx           # Context providers configuration
│   ├── rainbowkitConfig.tsx    # RainbowKit wallet configuration
│   └── vite-env.d.ts           # Vite environment type definitions
│
├── yoyoIndexer/                # Rindexer and graphql settings folder
│   ├── abis/                   # Contracts abis on json format
│   ├── .env                    # Environment variables for indexer
│   ├── .gitignore              # Git ignore rules
│   ├── docker-compose.yml      # docker settings
│   └── rindexer.yaml           # rindexer settings
│
├── public/                     # Public static files
├── node_modules/               # Dependencies
├── .env                        # Environment variables
├── .gitignore                  # Git ignore rules
├── eslint.config.js            # ESLint configuration
├── index.html                  # HTML entry point
├── package.json                # Project dependencies and scripts
├── tsconfig.json               # TypeScript configuration
└── vite.config.ts              # Vite build configuration
```

## 5.4. Custom Hooks

I created a custom hook for each interaction with smart contracts and queries.
In the hooks that need to read from contracts, I implemented a refetch logic based on event changes in order to optimize resource usage and costs. The contract state is treated as the final source of truth; however, before querying it directly, I rely on events to monitor state changes that indicate when a new contract read is required.

In the hooks that perform write operations on the contract, I use queries on indexed events to prevent transactions that would otherwise fail.

The hook structure is as follows: first, it uses queries to fetch events; then, it passes those events to a utility function that returns the condition to be checked. If the state has changed, the hook re-reads the contract; otherwise, it avoids an unnecessary refetch.

Each hook is documented with a NatSpec comment describing its internal logic and the components in which it is used.

### useClaimNft:

- Allows users who won an auction but experienced a failed NFT mint to claim their NFT
- Checks if the user has an unclaimed NFT and returns the tokenId

### useClaimRefund

- Allows users who experienced a failed Ether refund to claim their funds
- Checks if the user has unclaimed refunds and returns a boolean

### useCurrentAuction

- Fetches and monitors the current active auction data from the blockchain
- Implements a hybrid approach balancing security and performance optimization

### useEthereumPrice

- Fetches the current Ethereum price in USD from CoinGecko API for display purposes only
- Implements global caching to minimize API calls and improve performance
- **Note**: The price is used solely for UI estimation and does not interact with smart contracts or perform any critical calculations

### usePlaceBid

- Allows users to place bids on active auctions by sending ETH to the smart contract
- Handles bid amount conversion from ETH to Wei and manages transaction states
- Automatically refreshes auction data and bid history after successful bid placement

### useTransferNft

- Allows NFT owners to transfer their YoYo NFTs to another wallet address
- Handles the complete transfer transaction lifecycle with state management

### useUserNFTs

- Fetches and tracks all YoYo NFTs currently owned by a wallet address
- Calculates ownership by analyzing NFT transfer history (received vs sent)
- Supports checking NFTs for both the connected wallet and custom addresses

## 5.5. Redux For Global State

# 6. Performance, Gas Optimization And Security

## 6.1. Read Contract vs Read Events

## 6.2. Use Events To Trigger Read Contract

# 7. Further development

# 8. Contacts

For more information, questions, or collaboration opportunities, you can reach me:

- **GitHub**: [eliab256](https://github.com/eliab256)
- **Project Repository**: [Yoyo-Web3Dapp](https://github.com/eliab256/Yoyo-Web3Dapp)
- **Portfolio**: [elia-bordoni-blockchain-security-researcher.vercel.app](https://elia-bordoni-blockchain-security-researcher.vercel.app/)
- **Email**: bordonielia96@gmail.com
- **LinkedIn**: [Elia Bordoni](https://www.linkedin.com/in/elia-bordoni/)

# 9. Copyright

© 2026 Elia Bordoni. All rights reserved.
