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
  - [4.1. Rindexer with GraphQL](#41-rindexer-with-graphql)
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
    - [Store Structure](#store-structure)
    - [Example Slices](#example-slices)
    - [Usage in Components](#usage-in-components)
- [6. Performance, Gas Optimization And Security](#6-performance-gas-optimization-and-security)
  - [6.1. Read Contract vs Read Events](#61-read-contract-vs-read-events)
  - [6.2. Use Events To Trigger Read Contract](#62-use-events-to-trigger-read-contract)
- [7. Further development](#7-further-development)
- [8. Contacts](#8-contacts)
- [9. Copyright](#9-copyright)

# 1. About The Project

The project integrates React and TypeScript for the front end, Solidity and Foundry for smart contract development, and Wagmi together with Rindexer and GraphQL to handle the interaction between smart contracts and the front end.

The project is developed across four main pages: Home (the landing page), the Auction page, which contains all the details of the ongoing auction, My NFTs, where each user can view a summary of their owned NFTs, and About Us, which provides information about the project’s history and mission.

Each NFT has its own dedicated page where all details can be explored and, if the user owns the NFT, it also provides the ability to transfer it to another user.

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

The project uses three different `.env` files.
Each `.env` file has a corresponding `example.env` file to simplify environment configuration.

**Foundry `.env`**
The first `.env` file is located in the **Foundry** directory and is used to run tests on **Sepolia network forks**.

**yoyoIndexer `.env`**
The second `.env` file is located inside the **yoyoIndexer** directory and is used to configure the **PostgreSQL database** for reading and indexing on-chain events.

**Root `.env`**
The third `.env` file is located in the **project root** and contains the following configuration values:

- the `wallet_connect_project_id` used by **RainbowKit**
- the **Sepolia RPC URL** (Alchemy is recommended)
- the **indexer URLs** for both **development** and **production** environments

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

The Yoyo Web3App reads data from smart contracts using the `useReadContract` hook from the Wagmi library, integrated within custom React hooks.

- **Current Auction Data**: The `useCurrentAuction` hook uses `useReadContract` to fetch the current auction's details directly from the blockchain. To optimize performance, the hook only triggers a blockchain read when relevant auction events (like opening or closing) are detected via the event indexer.

## 3.3. Write on Smart Contracts

All write operations to the smart contracts are handled using the `useWriteContract` hook from Wagmi, wrapped in custom hooks to manage transaction state, error handling, and UI updates.

- **Placing Bids**: The `usePlaceBid` hook calls the `placeBidOnAuction` function on the YoyoAuction contract, submitting the user's bid and value. After confirmation, it automatically refreshes auction and bid data to reflect the new state.
- **Claiming NFTs**: The `useClaimNft` hook allows users to recover NFTs when a mint fails by calling `claimNftForWinner` on the contract. It cross-references indexed events to determine eligibility and updates the UI after a successful claim.
- **Claiming Refunds**: The `useClaimRefund` hook enables users to reclaim failed Ether refunds by calling `claimFailedRefunds`. It checks for unclaimed refunds using indexed events and updates the UI after confirmation.
- **Transferring NFTs**: The `useTransferNft` hook provides a secure interface for users to transfer their YoYo NFTs to another address by calling `transferNft` on the contract, with full transaction state management.

All write hooks are chain-aware, automatically selecting the correct contract address based on the connected network, and use React Query to invalidate and refetch relevant data after successful transactions, ensuring the UI remains consistent and up-to-date.

# 4. Event Indexing

Event indexing is a crucial part of the Yoyo Web3App architecture. By indexing smart contract events, the application can efficiently query historical and real-time blockchain data, enabling features such as bid history, auction lifecycle tracking, NFT ownership, and refund status. The event indexer ensures that the frontend can access and display up-to-date information without directly querying the blockchain for every request, improving both performance and user experience.

## 4.1. Rindexer with GraphQL

The project uses **Rindexer**, a no-code blockchain event indexer, to capture and store relevant events emitted by the YoyoAuction and YoyoNft smart contracts. Rindexer is configured via the `rindexer.yaml` file to listen to specific events on the Sepolia network. The indexed data is made available through a GraphQL API, which the frontend queries to retrieve auction, bid, NFT, and refund information.

Key configuration points:

- **Network**: Sepolia (chain ID 11155111)
- **Contracts indexed**: YoyoAuction, YoyoNft
- **Events indexed**: All relevant auction, bid, NFT, and refund events (see below)
- **Storage**: PostgreSQL database
- **API**: GraphQL endpoint for efficient data access

railway domain for rindexer
https://rindexer-sepolia-yoyo-production.up.railway.app


## 4.2. Indexed Events

The following events are indexed for each contract:

**YoyoAuction**

- YoyoAuction\_\_BidPlaced
- YoyoAuction\_\_BidderRefunded
- YoyoAuction\_\_BidderRefundFailed
- YoyoAuction\_\_AuctionOpened
- YoyoAuction\_\_AuctionRestarted
- YoyoAuction\_\_AuctionClosed
- YoyoAuction\_\_AuctionFinalized
- YoyoAuction\_\_MintFailed
- YoyoAuction\_\_ManualUpkeepExecuted

**YoyoNft**

- YoyoNft\_\_WithdrawCompleted
- YoyoNft\_\_DepositCompleted
- YoyoNft\_\_MintPriceUpdated
- YoyoNft\_\_NftMinted
- Transfer

These events provide all the necessary data to reconstruct auction states, bid histories, NFT transfers, and user balances.

## 4.3. Queries

The frontend interacts with the indexed data using GraphQL queries. Some of the main queries include:

- **GetReceivedNFTs / GetSentNFTs**: Retrieve all NFT transfers to/from a specific address.
- **GetAuctionBids**: Fetch the bid history for a given auction ID.
- **GetAuctionsLifecycle**: Get the opening and closing events for all auctions.
- **GetBidderRefunds / GetBidderFailedRefunds**: Check refund and failed refund events for a user.
- **GetAllFinalizedAuctions**: List all finalized auctions and their winners.
- **GetAllMintFailed**: Find all failed NFT mint attempts for a user.

These queries are defined in the `src/graphql/queries.ts` file and are used throughout the frontend to provide real-time and historical data to users. The GraphQL client in `src/graphql/client.ts` handles the actual API requests and data formatting.

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

The Yoyo Web3App uses **Redux Toolkit** for global state management, ensuring a predictable and centralized way to handle application state across all components. Redux is especially useful for managing UI state, user selections, and cross-component communication in a scalable React application.

### Store Structure

The Redux store is configured in `src/redux/store.ts` and combines several slices:

- `currentPage`: Manages the currently open page in the app.
- `selectedNft`: Tracks the NFT selected by the user for actions like viewing details or transferring.
- `confirmPlaceBid`: Handles the state for the bid confirmation panel, including flags for user eligibility, balance, and unclaimed tokens.

### Example Slices

- **selectedNftSlice**: Stores the selected NFT's token ID and provides actions to set or clear the selection.
- **confirmPlaceBidSlice**: Manages the state of the bid confirmation modal, including whether it is open, if the user is already the highest bidder, balance checks, and unclaimed token status. It also provides selectors for easy access to these states in components.

### Usage in Components

Components use the `useSelector` hook to read state and the `useDispatch` hook to update state. This allows for seamless UI updates and consistent state across the app. For example, the main `App.tsx` component uses Redux to determine which page to display, and the auction components use Redux to manage bid confirmation and NFT selection workflows.

By leveraging Redux Toolkit, the app achieves modular, maintainable, and testable state management, supporting a smooth user experience even as the application grows in complexity.

# 6. Performance, Gas Optimization And Security

## 6.1. Read Contract vs Read Events

## 6.2. Use Events To Trigger Read Contract

# 7. Further development

The Yoyo Web3App is designed with extensibility and future improvements in mind. Potential areas for further development include:

- **Multi-chain Support**: Expanding compatibility to additional EVM-compatible networks beyond Sepolia, allowing users to participate in auctions and manage NFTs across multiple blockchains.
- **Auction Types**: Introducing new auction formats (e.g. sealed-bid, or batch auctions) to provide more flexibility and engagement for users.
- **Enhanced Marketplace Features**: Adding direct NFT trading, secondary sales, and bidding on existing NFTs to create a more dynamic and liquid marketplace.
- **User Profiles and Social Features**: Implementing user profiles, activity feeds, and social sharing to foster a stronger community around the platform.
- **Analytics and Insights**: Providing users and creators with analytics dashboards to track auction performance, NFT value trends, and user engagement.
- **On-chain Governance**: Enabling community-driven governance for platform upgrades, auction rules, and feature prioritization through token-based voting.
- **Integration with Other Protocols**: Connecting with DeFi, staking, or lending protocols to unlock new utility for NFTs and auction proceeds.

Contributions and suggestions are welcome! If you have ideas or want to collaborate, please open an issue or submit a pull request.

# 8. Contacts

For more information, questions, or collaboration opportunities, you can reach me:

- **GitHub**: [eliab256](https://github.com/eliab256)
- **Project Repository**: [Yoyo-Web3Dapp](https://github.com/eliab256/Yoyo-Web3Dapp)
- **Portfolio**: [elia-bordoni-blockchain-security-researcher.vercel.app](https://elia-bordoni-blockchain-security-researcher.vercel.app/)
- **Email**: bordonielia96@gmail.com
- **LinkedIn**: [Elia Bordoni](https://www.linkedin.com/in/elia-bordoni/)

# 9. Copyright

© 2026 Elia Bordoni. All rights reserved.
