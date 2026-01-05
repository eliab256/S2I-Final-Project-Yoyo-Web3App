export interface NftMetadata {
    name: string;
    description: string;
    image: string; // CID of png image "ipfs://..."
    attributes: Array<{
        trait_type: string;
        value: string | number;
    }>;
    properties: {
        category: string;
        course_type: string;
        accessibility_level: string;
        redeemable: boolean;
        instructor_certified: boolean;
        style: string;
    };
}

export interface NftData {
    metadata: NftMetadata;
    tokenId: number;
    image: string;
}

export interface NftTransferEvent {
    from: string;
    to: string;
    token_id: string;
    tx_hash: string;
    block_number: number;
    block_timestamp: number;
    log_index: number;
    transaction_index: number;
}

export interface NftMintedEvent {
  _to: string;
  _token_id: string;
  token_uri_complete: string;
  tx_hash: string;
  block_number: number;
  block_timestamp: number;
  log_index: number;
  transaction_index: number;
}


export interface NftEventsCombined {
  token_id: number;              
  token_uri_complete: string;
  mint_timestamp: number;
  current_owner: string;
  transfer_timestamp?: number;  
}
