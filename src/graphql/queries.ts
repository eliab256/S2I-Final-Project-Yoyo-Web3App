export const GET_RECEIVED_NFTS = `
query GetReceivedNFTs($ownerAddress){
  allTransfers (
    condition: {to: $ownerAddress}
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
query GetSentNFTs($ownerAddress){
  allTransfers (
    condition: {from: $ownerAddress}
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
