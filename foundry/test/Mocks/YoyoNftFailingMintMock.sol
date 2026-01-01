// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721 } from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import { ConstructorParams } from '../../src/YoyoTypes.sol';
import '../../src/YoyoNft/YoyoNftErrors.sol';
import '../../src/YoyoNft/YoyoNftEvents.sol';

/**
 * @title YoyoNft Mock Contract for Testing Mint Failures
 * @author Elia Bordoni
 * @notice Mock contract that simulates different mint failure scenarios for testing purposes
 * @dev Extends YoyoNft functionality with configurable failure modes:
 *      - Standard revert with custom error message (via setShouldFailMint)
 *      - Panic errors using invalid opcode (via setShouldPanic)
 * @dev Use setShouldFailMint(true, "reason") to make mintNft revert with a specific message
 * @dev Use setShouldPanic(true) to make mintNft trigger a panic error (caught by generic catch block)
 * @dev Reset failure modes by setting flags to false before testing successful mints
 */

contract YoyoNftFailingMintMock is ERC721, Ownable {
    /* Errors */
    /**
     * @dev Errors are declared in YoyoNftErrors.sol
     */

    /* State variables */
    uint256 public constant MAX_NFT_SUPPLY = 20;
    address private immutable i_auctionContract;
    uint256 private s_tokenCounter;
    uint256 private s_basicMintPrice;
    string private s_baseURI;

    bool shouldFailMint;
    bool shouldPanic;
    string failureReason;

    /* Events */
    /**
     * @dev Events are declared in YoyoNftEvents.sol
     */

    /* Modifiers */

    modifier onlyAuction() {
        if (msg.sender != i_auctionContract) {
            revert YoyoNft__NotAuctionContract();
        }
        _;
    }

    /**
     * @notice The ERC721 token is inizialized with the name "Yoyo Collection" and with the symbol "YOYO"
     * @dev The owner of the contract is set to be the sender of the deployment transaction
     */
    constructor(ConstructorParams memory _params) ERC721('Yoyo Collection', 'YOYO') Ownable(msg.sender) {
        if (bytes(_params.baseURI).length == 0) {
            revert YoyoNft__ValueCantBeZero();
        }
        if (_params.auctionContract == address(0)) {
            revert YoyoNft__InvalidAddress();
        }
        s_baseURI = _params.baseURI;
        s_tokenCounter = 0;
        i_auctionContract = _params.auctionContract;
        s_basicMintPrice = _params.basicMintPrice;
    }

    /* Functions */
    /**
     *@dev both receive and fallback functions refuse to accept eth and force users
     *@dev to use correct functions
     */
    receive() external payable {
        revert YoyoNft__ThisContractDoesntAcceptDeposit();
    }

    fallback() external payable {
        revert YoyoNft__CallValidFunctionToInteractWithContract();
    }

    /**
     *@notice allows only the owner of the contract to widthraw founds from contract
     */
    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        if (contractBalance == 0) {
            revert YoyoNft__ContractBalanceIsZero();
        }
        (bool success, ) = payable(owner()).call{ value: contractBalance }('');
        if (success) {
            emit YoyoNft__WithdrawCompleted(contractBalance, block.timestamp);
        } else {
            revert YoyoNft__WithdrawFailed();
        }
    }

    /**
     *@notice allows only the owner of the contract to deposit founds
     */
    function deposit() public payable onlyOwner {
        if (msg.value == 0) {
            revert YoyoNft__ValueCantBeZero();
        }
        emit YoyoNft__DepositCompleted(msg.value, block.timestamp);
    }

    /**
     *@notice It allows setting the base minting price from the auction contract.
     *@dev This is because the logic of the auction contract must prevent the winner’s
     *@dev auction price from being in any way lower than the mint price, which would
     *@dev result in the minting process failing.
     *@param _newBasicPrice  is the new minting price
     */
    function setBasicMintPrice(uint256 _newBasicPrice) public onlyAuction {
        if (_newBasicPrice == 0) {
            revert YoyoNft__ValueCantBeZero();
        }
        s_basicMintPrice = _newBasicPrice;

        emit YoyoNft__MintPriceUpdated(_newBasicPrice, block.timestamp);
    }

    function setShouldFailMint(bool _shouldFail, string memory _reason) external {
        shouldFailMint = _shouldFail;
        failureReason = _reason;
    }

    /**
     * @dev Configures the mock to panic (without an error message)
     */
    function setShouldPanic(bool _shouldPanic) external {
        shouldPanic = _shouldPanic;
    }

    /**
     *@notice It allows auction contract to mint a new Nft to send to the auction winner
     *@dev Implementation of the safeMint function from ERC721 standard
     *@dev create the event whit all the information for the frontend like tokenURI and tokenId
     *@dev update tokenCounter to avoid max supply exceed
     *@param _to it is the recipient to whom the NFT will be sent immediately after it is minted.
     *@param _tokenId it is the unique Id of the token just minted
     */
    function mintNft(address _to, uint256 _tokenId) public payable onlyAuction {
        if (shouldPanic) {
            // Triggers a panic (caught by generic catch)
            assembly {
                invalid() // Invalid opcode
            }
        }

        if (shouldFailMint) {
            // Revert with message (caught by catch Error)
            revert(failureReason);
        }

        if (s_tokenCounter == MAX_NFT_SUPPLY) {
            revert YoyoNft__NftMaxSupplyReached();
        }
        if (_ownerOf(_tokenId) != address(0)) {
            revert YoyoNft__NftAlreadyMinted();
        }
        if (_tokenId >= MAX_NFT_SUPPLY) {
            revert YoyoNft__TokenIdDoesNotExist();
        }
        if (msg.value < s_basicMintPrice) {
            revert YoyoNft__NotEnoughEtherSent();
        }
        if (_to == address(0)) {
            revert YoyoNft__InvalidAddress();
        }
        _safeMint(_to, _tokenId);
        string memory tokenURIComplete = tokenURI(_tokenId);
        s_tokenCounter++;

        emit YoyoNft__NftMinted(_to, _tokenId, tokenURIComplete, block.timestamp);
    }

    /**
     *@notice Allows nft owner to transfer his nft to another user
     *@dev Implementation of the safeTransfer function from ERC721 standard
     *@dev create the event whit all the information for the frontend like tokenId and new owner
     *@param _to it is the recipient to whom the NFT will be sent.
     *@param _tokenId it is the unique Id of the token to send.
     */
    function transferNft(address _to, uint256 _tokenId) public {
        if (_to == address(0)) {
            revert YoyoNft__InvalidAddress();
        }
        if (ownerOf(_tokenId) != msg.sender) {
            revert YoyoNft__NotNftOwner();
        }
        _safeTransfer(msg.sender, _to, _tokenId);
    }

    /**
     *@notice Return the complete URI of a specific token from his Id
     *@param _tokenId it is the unique Id of the token.
     *@return tokenURI the complete unique URI related to the specific token
     */
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        if (_tokenId >= MAX_NFT_SUPPLY) {
            revert YoyoNft__TokenIdDoesNotExist();
        }
        if (_ownerOf(_tokenId) == address(0)) {
            revert YoyoNft__NftNotMinted();
        }
        return string(abi.encodePacked(s_baseURI, '/', Strings.toString(_tokenId), '.json'));
    }

    function getBaseURI() public view returns (string memory) {
        return s_baseURI;
    }

    function getTotalMinted() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getOwnerFromTokenId(uint256 tokenId) public view returns (address) {
        return ownerOf(tokenId);
    }

    function getAccountBalance(address _account) public view returns (uint256) {
        return balanceOf(_account);
    }

    function getAuctionContract() public view returns (address) {
        return i_auctionContract;
    }

    function getBasicMintPrice() public view returns (uint256) {
        return s_basicMintPrice;
    }

    /**
     *@notice Checks whether a specific token ID can be minted or not.
     *@notice This means it verifies both whether it has already been minted
     *@notice and whether the ID is within the maximum supply.
     *@param _tokenId it is the unique Id of the token that user want to check.
     *@return boolean after check is complete, return fi is mintable (true) or not mintable (false)
     */
    function getIfTokenIdIsMintable(uint256 _tokenId) public view returns (bool) {
        return _ownerOf(_tokenId) == address(0) && _tokenId < MAX_NFT_SUPPLY;
    }
}
