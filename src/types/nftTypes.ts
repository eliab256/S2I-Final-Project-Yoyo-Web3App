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
