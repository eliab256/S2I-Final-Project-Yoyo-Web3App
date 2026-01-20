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

## 3.2. Read From Smart Contracts

## 3.3. Write on Smart Contracts

# 4. Event Indexing

## 4.1. Rindexer with graphql

## 4.2. Indexed Events

## 4.3. Queries

# 5. Front End

## 5.1. Providers

## 5.2. Wallet Connection

## 5.3. App Structure

## 5.4. Custom Hooks

## 5.5. Redux For Global State

# 6. Performance, Gas Optimization And Security

## 6.1. Read Contract vs Read Events

## 6.2. Use Events To Trigger Read Contract

# 7. Further development

# 8. Contacts

# 9. Copyright
