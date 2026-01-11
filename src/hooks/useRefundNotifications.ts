import { useQuery } from '@tanstack/react-query';
import { useAccount } from 'wagmi';
import { useState, useEffect } from 'react';
import { getBidderRefundsByAddress } from '../graphql/client';
import { getViewedRefunds, markRefundAsViewed } from '../utils/refundStorage';
import type { BidderRefund } from '../types/queriesTypes';

export function useRefundNotifications() {
    const { address, isConnected } = useAccount();
    const [pendingRefund, setPendingRefund] = useState<BidderRefund | null>(null);
    // Query refunds per l'utente connesso
    const { data: refunds } = useQuery({
        queryKey: ['userRefunds', address],
        queryFn: () => getBidderRefundsByAddress(address!),
        enabled: !!address && isConnected,
        refetchInterval: 60000, // Controlla ogni 60s
    });

    useEffect(() => {
        if (!address || !refunds || refunds.length === 0) {
            setPendingRefund(null);
            return;
        }

        const viewedRefunds = getViewedRefunds(address);

        // Trova il primo refund non ancora visualizzato
        const unviewedRefund = refunds.find(refund => !viewedRefunds.includes(refund.txHash));

        if (unviewedRefund) {
            setPendingRefund(unviewedRefund);
        } else {
            setPendingRefund(null);
        }
    }, [address, refunds]);

    const dismissRefund = () => {
        if (pendingRefund && address) {
            markRefundAsViewed(address, pendingRefund.txHash);
            setPendingRefund(null);
        }
    };

    return {
        pendingRefund,
        dismissRefund,
        hasUnviewedRefund: !!pendingRefund,
    };
}
