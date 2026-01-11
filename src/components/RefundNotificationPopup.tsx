import { formatEther } from 'viem';
import type { BidderRefund } from '../types/queriesTypes';
import { formatStartDate } from '../utils/timeUtils';
interface RefundNotificationPopupProps {
    refund: BidderRefund | null;
    onDismiss: () => void;
}

function RefundNotificationPopup({ refund, onDismiss }: RefundNotificationPopupProps) {
    if (!refund) return null;

    return (
        <div className="absolute top-0 right-0 z-50 h-1/2 w-full max-w-md p-4">
            <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl h-full p-6 flex flex-col">
                <h2 className="text-xl font-bold mb-4">🔔 Bid Refunded</h2>

                <div className="space-y-4 mb-6 flex-1">
                    <p className="text-gray-600 dark:text-gray-400">
                        Your bid has been outbid and you have been refunded.
                    </p>

                    <div className="bg-gray-100 dark:bg-gray-700 rounded-lg p-4 space-y-2">
                        <div className="flex justify-between">
                            <span className="font-medium">Refunded at:</span>
                            <span className="font-mono">{formatStartDate(BigInt(refund.blockTimestamp))}</span>
                        </div>
                        <div className="flex justify-between">
                            <span className="font-medium">Refund Amount:</span>
                            <span className="font-mono font-bold">{formatEther(BigInt(refund.bidAmount))} ETH</span>
                        </div>
                    </div>
                </div>

                <button
                    onClick={onDismiss}
                    className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors"
                >
                    OK
                </button>
            </div>
        </div>
    );
}

export default RefundNotificationPopup;
