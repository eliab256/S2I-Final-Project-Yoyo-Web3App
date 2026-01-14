export const GET_RECEIVED_NFTS = `
  query GetReceivedNFTs($ownerAddress: String!) {
    allTransfers(
      condition: { to: $ownerAddress }
      orderBy: BLOCK_TIMESTAMP_DESC
    ) {
      nodes {
        from
        to
        tokenId
        txHash
        blockNumber
        blockTimestamp
      }
    }
  }
`;

export const GET_SENT_NFTS = `
  query GetSentNFTs($ownerAddress: String!) {
    allTransfers(
      condition: { from: $ownerAddress }
      orderBy: BLOCK_TIMESTAMP_DESC
    ) {
      nodes {
        from
        to
        tokenId
        txHash
        blockNumber
        blockTimestamp
      }
    }
  }
`;

export const GET_BID_HYSTORY_FROM_AUCTION_ID = `
  query GetAuctionBids($auctionId: String!) {
  allYoyoAuctionBidPlaceds(
    condition: { auctionId: $auctionId }
    orderBy: BLOCK_TIMESTAMP_DESC
  ) {
    nodes {
      auctionId
      bidAmount       
      bidder                
      blockTimestamp  
      blockNumber     
      txHash          
    }
  }
}
`;

export const GET_AUCTIONS_LIFECYCLE = `
  query GetAuctionsLifecycle {
    allYoyoAuctionAuctionOpeneds {
      nodes {
        auctionId
        blockTimestamp
        blockNumber
        endTime
      }
    }
    allYoyoAuctionAuctionCloseds {
      nodes {
        auctionId
        blockTimestamp
        blockNumber
      }
    }
  }
`;

export const GET_BIDDER_REFUNDS = `
  query GetAuctionsLifecycle($addr: String!) {
    allYoyoAuctionBidderRefundeds(
      filter: { prevBidderAddress: { equalTo: $addr } }
    ) {
      nodes {
        prevBidderAddress
        bidAmount
        blockNumber
        blockTimestamp
        txHash
      }
    }
  }
`;

export const GET_BIDDER_FAILED_REFUNDS = `
  query GetFailedRefunds($addr: String!) {
    allYoyoAuctionBidderRefundFaileds(
      condition:  {
        prevBidderAddress: $addr
      }
      orderBy: BLOCK_TIMESTAMP_DESC
    ) {
      nodes {
        prevBidderAddress
        bidAmount
        blockNumber
        blockTimestamp
        txHash
      }
    }
  }
`;
