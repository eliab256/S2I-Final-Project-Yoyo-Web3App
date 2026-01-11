import type { TransferEvent } from '../types/queriesTypes';
import type {OwnedNFT} from "../types/queriesTypes";

function getOwnedNFTs(received: TransferEvent[], sent: TransferEvent[]): OwnedNFT[] {
    return received
        .filter(
            r =>
                // check if the tokenId is not in the sent array
                !sent.some(s => s.tokenId === r.tokenId)
        )
        .map(transfer => ({
            // map to OwnedNFT format
            tokenId: transfer.tokenId,
            mintedAt: transfer.blockTimestamp,
            mintTxHash: transfer.txHash,
        }));
}

export default getOwnedNFTs;
