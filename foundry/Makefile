-include .env

.PHONY: test test-auction test-nft test-library test-setup coverage deploy-sepolia

test :; forge test -vv

# Single test by name (usage: make test-single NAME=testFunctionName)
test-name :; forge test --match-test $(NAME) -vvv

# Test for specific file in YoyoAuctionTest folder (usage: make test-file FILE=YoyoAuction.PlaceBid.t.sol)
test-file :; forge test --match-path test/YoyoAuctionTest/YoyoAuction.$(FILE).t.sol -vvv

# Test for specific folder/file
test-auction :; forge test --match-path test/YoyoAuctionTest/*.sol -vv

test-nft :; forge test --match-path test/YoyoNft.t.sol -vv

test-library :; forge test --match-path test/YoyoAuctionTest/YoyoDutchAuctionLibrary.t.sol -vv

test-deploy :; forge test --match-path test/DeployYoyoAuctionAndYoyoNft.t.sol -vv

# Test with fork on Sepolia 
test-fork-sepolia:
	forge test --fork-url $(ETHEREUM_SEPOLIA_RPC_URL)

test-name-sepolia:
	forge test --fork-url $(ETHEREUM_SEPOLIA_RPC_URL) --match-test $(NAME) -vvv

# Test with fork on Mainnet 
test-fork-mainnet:
	forge test --fork-url $(ETHEREUM_MAINNET_RPC_URL)

# Coverage only for main contracts (excludes mocks, interfaces, tests, helpers)
coverage-main :; forge coverage --report summary \
	--no-match-coverage "Mock|Test|Interface|I[A-Z]|CodeConstants|AutomationRegistration"

# Coverage with lcov report for main contracts
coverage-lcov :; forge coverage --report lcov \
	--no-match-coverage "Mock|Test|Interface|I[A-Z]|CodeConstants"

# Detailed coverage with uncovered lines report (debug)
coverage-main-report :; forge coverage --report debug \
	--no-match-coverage "Mock|Test|Interface|I[A-Z]|CodeConstants" \
	> coverage-report.txt && \
	echo "Report saved in coverage-report.txt"
	
# Gas report
gas-report :; forge test --gas-report

deploy-sepolia :
	@forge script script/DeployYoyoAuctionAndYoyoNft.s.sol:DeployYoyoAuctionAndYoyoNft \
		--rpc-url $(ETHEREUM_SEPOLIA_RPC_URL) --private-key $(ETHEREUM_PRIVATE_KEY) \
		--broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv