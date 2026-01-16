import type { FinalizedAuction, FailedMint } from '../types/queriesTypes';

function getUnclaimedTokens(failedMints: FailedMint[], finalizedAuctions: FinalizedAuction[]): FailedMint | null {
    if (failedMints.length === 0) return null;
    if (finalizedAuctions.length === 0) return failedMints[0];
    const unclaimed = failedMints.find(r => !finalizedAuctions.some(f => f.tokenId === r.tokenId));
    return unclaimed ?? null;
}

export default getUnclaimedTokens;
