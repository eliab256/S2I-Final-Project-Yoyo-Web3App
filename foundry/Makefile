-include .env

.PHONY: build test test-auction test-nft test-library test-setup coverage deploy-sepolia

build :; forge build

test :; forge test -vv

# Test singolo per nome (uso: make test-single NAME=testNomeFunzione)
test-name :; forge test --match-test $(NAME) -vvv

# Test per file specifico nella cartella YoyoAuctionTest (uso: make test-file FILE=YoyoAuction.PlaceBid.t.sol)
test-file :; forge test --match-path test/YoyoAuctionTest/YoyoAuction.$(FILE).t.sol -vvv

# Test per cartella/file specifico
test-auction :; forge test --match-path test/YoyoAuctionTest/*.sol -vv

test-nft :; forge test --match-path test/YoyoNft.t.sol -vv

test-library :; forge test --match-path test/YoyoAuctionTest/YoyoDutchAuctionLibrary.t.sol -vv

test-deploy :; forge test --match-path test/DeployYoyoAuctionAndYoyoNft.t.sol -vv

# Test with fork on Sepolia 
test-fork-sepolia:
	forge test --fork-url $(ETHEREUM_SEPOLIA_RPC_URL)

# Test with fork on Mainnet 
test-fork-mainnet:
	forge test --fork-url $(ETHEREUM_MAINNET_RPC_URL)

# Coverage
coverage :; forge coverage

# Coverage only for main contracts (excludes mocks, interfaces, tests, helpers)
coverage-main :; forge coverage --report summary \
	--no-match-coverage "Mock|Test|Interface|I[A-Z]|CodeConstants"

# Coverage with lcov report for main contracts
coverage-lcov :; forge coverage --report lcov \
	--no-match-coverage "Mock|Test|Interface|I[A-Z]|CodeConstants"

# Detailed coverage with uncovered lines report (debug)
coverage-main-report :; forge coverage --report debug \
	--no-match-coverage "Mock|Test|Interface|I[A-Z]|CodeConstants" \
	> coverage-report.txt && \
	echo "Report saved in coverage-report.txt"

# Coverage ONLY for uncovered lines/branches/statements (filtered)
coverage-uncovered :; forge coverage --report debug \
	--no-match-coverage "Mock|Test|Interface|I[A-Z]|CodeConstants" 2>&1 | \
	grep -v -E "(Mock|Test|Interface|I[A-Z].*\.sol|CodeConstants)" | \
	grep -E "(Uncovered|src/|\.sol|Hit:0|not covered|0/[0-9])" > coverage-uncovered.txt && \
	echo "Uncovered lines report saved in coverage-uncovered.txt"
	
# Gas report
gas-report :; forge test --gas-report

deploy-sepolia :
	@forge script script/DeployYoyoAuctionAndYoyoNft.s.sol:DeployYoyoAuctionAndYoyoNft --rpc-url $(ETHEREUM_SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)  -vvvv	