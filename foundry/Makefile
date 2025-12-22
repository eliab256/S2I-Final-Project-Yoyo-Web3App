-include .env

.PHONY: build test test-auction test-nft test-library test-setup coverage deploy-sepolia

build :; forge build

test :; forge test -vv

# Test per cartella/file specifico
test-auction :; forge test --match-path test/YoyoAuctionTest/*.sol -vv

test-nft :; forge test --match-path test/YoyoNft.t.sol -vv

test-library :; forge test --match-path test/YoyoAuctionTest/YoyoDutchAuctionLibrary.t.sol -vv

test-deploy :; forge test --match-path test/DeployYoyoAuctionAndYoyoNft.t.sol -vv


# Coverage
coverage :; forge coverage

# Coverage solo per contratti principali (esclude mocks, interfaces, test, helpers)
coverage-main :; forge coverage --report summary \
	--no-match-coverage "Mock|Test|Interface|I[A-Z]|CodeConstants"

# Coverage con report lcov per contratti principali
coverage-lcov :; forge coverage --report lcov \
	--no-match-coverage "Mock|Test|Interface|I[A-Z]|CodeConstants"

# Coverage dettagliato con report delle linee non coperte (debug)
coverage-main-report :; forge coverage --report debug \
	--no-match-coverage "Mock|Test|Interface|I[A-Z]|CodeConstants" \
	> coverage-report.txt && \
	echo "Report salvato in coverage-report.txt"

# Coverage SOLO righe/branch/statement non coperti (filtrato)
coverage-uncovered :; forge coverage --report debug \
	--no-match-coverage "Mock|Test|Interface|I[A-Z]|CodeConstants" 2>&1 | \
	grep -E "(Uncovered|src/|\.sol|Hit:0|not covered|0/[0-9])" > coverage-uncovered.txt && \
	echo "Report delle righe non coperte salvato in coverage-uncovered.txt"

# Gas report
gas-report :; forge test --gas-report

deploy-sepolia :
	@forge script script/DeployYoyoAuctionAndYoyoNft.s.sol:DeployYoyoAuctionAndYoyoNft --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)  -vvvv	