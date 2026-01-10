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
