import type {BidderRefund} from '../types/queriesTypes';



function getUnclaimedRefund(claimedRefund:BidderRefund[] , allRefunds: BidderRefund[]): boolean {
    // Logica per ottenere il rimborso non reclamato
    if (allRefunds.length - claimedRefund.length === 0) return false;
    return true;
}

export default getUnclaimedRefund;