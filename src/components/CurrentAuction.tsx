import useCurrentAuction from '../hooks/useCurrentAuction';
import NftCard from './NftCard';
import { formatEther } from 'viem';
import { useMemo, useState, useEffect } from 'react';
import useEthereumPrice from '../hooks/useEthereumPrice';

const CurrentAuction: React.FC = () => {
    const { auction, isLoading } = useCurrentAuction();
    const { price: ethPriceUSD } = useEthereumPrice();
    const [bidValue, setBidValue] = useState<string>('');
    const [nftDetails, setNftDetails] = useState<boolean>(false);
    const [timeRemaining, setTimeRemaining] = useState<number>(0);

    const getUsdPrice = useMemo(() => {
        return (ethAmount: bigint | undefined) => {
            if (!ethAmount || !ethPriceUSD) return '0.00';
            try {
                const ethValue = parseFloat(formatEther(ethAmount));
                return (ethValue * ethPriceUSD).toFixed(2);
            } catch {
                return '0.00';
            }
        };
    }, [ethPriceUSD]);

    // Calcola USD per il valore inserito dall'utente
    const userBidUsd = useMemo(() => {
        if (!bidValue || !ethPriceUSD) return '0.00';
        try {
            const ethValue = parseFloat(bidValue);
            if (isNaN(ethValue)) return '0.00';
            return (ethValue * ethPriceUSD).toFixed(2);
        } catch {
            return '0.00';
        }
    }, [bidValue, ethPriceUSD]);

    // Decostruzione della struct auction
    const {
        auctionId,
        tokenId,
        nftOwner,
        auctionState,
        auctionType,
        startPrice,
        startTime,
        endTime,
        higherBidder,
        higherBid,
        minimumBidChangeAmount,
    } = auction || {};

    // Countdown timer
    useEffect(() => {
        if (!endTime) return;

        const updateTimer = () => {
            const now = Math.floor(Date.now() / 1000);
            const remaining = Number(endTime) - now;
            setTimeRemaining(remaining > 0 ? remaining : 0);
        };

        updateTimer();
        const interval = setInterval(updateTimer, 1000);

        return () => clearInterval(interval);
    }, [endTime]);

    // Formatta il tempo rimanente
    const formatTime = (seconds: number) => {
        const days = Math.floor(seconds / 86400);
        const hours = Math.floor((seconds % 86400) / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;

        if (days > 0) {
            return `${days}d ${hours}h ${minutes}m ${secs}s`;
        } else if (hours > 0) {
            return `${hours}h ${minutes}m ${secs}s`;
        } else if (minutes > 0) {
            return `${minutes}m ${secs}s`;
        } else {
            return `${secs}s`;
        }
    };

    // Formatta la data di inizio
    const formatStartDate = (timestamp: bigint | undefined) => {
        if (!timestamp) return '';
        const date = new Date(Number(timestamp) * 1000);
        return date.toLocaleString();
    };

    return (
        <div className="w-full px-2 sm:px-4 lg:min-h-[calc(100vh-var(--headerAndFooterHeight)*2)]">
            <h1>Current Auction</h1>
            {isLoading ? (
                <div className="flex items-center justify-center min-h-[50vh]">
                    <div className="text-xl">Loading current auction...</div>
                </div>
            ) : tokenId !== undefined ? (
                <>
                    <h2>Auction ID: {auctionId}</h2>
                    <div className="flex flex-col lg:flex-row gap-6 items-start justify-center mt-6">
                        <NftCard tokenId={Number(tokenId)} />
                        <div className="max-w-md w-full p-6 bg-white rounded-xl shadow-lg">
                            <h2 className="text-2xl font-bold text-center mb-4">Place Your Bid Here</h2>
                            <p className="text-lg text-center mb-6 w-full">
                                This is {auctionType === 0 ? 'an English' : 'a Dutch'} auction
                            </p>

                            <div className="space-y-3">
                                <div className="flex justify-between items-center">
                                    <span className="font-semibold">Starting Price:</span>
                                    <span className="text-lg">
                                        {startPrice ? formatEther(startPrice) : '0'} ETH ≈ ${getUsdPrice(startPrice)}
                                    </span>
                                </div>

                                {auctionType === 0 && (
                                    <>
                                        <div className="flex justify-between items-center">
                                            <span className="font-semibold">Min. Bid Increment:</span>
                                            <span className="text-lg">
                                                {minimumBidChangeAmount ? formatEther(minimumBidChangeAmount) : '0'} ETH
                                                ≈ ${getUsdPrice(minimumBidChangeAmount)}
                                            </span>
                                        </div>
                                        <div className="flex justify-between items-center">
                                            <span className="font-semibold">Current Highest Bid:</span>
                                            <span className="text-lg font-bold text-green-600">
                                                {higherBid ? formatEther(higherBid) : '0'} ETH ≈ $
                                                {getUsdPrice(higherBid)}
                                            </span>
                                        </div>
                                    </>
                                )}

                                {auctionType === 1 && (
                                    <div className="flex justify-between items-center">
                                        <span className="font-semibold">Current Price:</span>
                                        <span className="text-lg font-bold text-blue-600">
                                            {higherBid ? formatEther(higherBid) : '0'} ETH ≈ ${getUsdPrice(higherBid)}
                                        </span>
                                    </div>
                                )}

                                <div className="mt-6 pt-4 border-t border-gray-200">
                                    <label className="block font-semibold mb-2">Your Offer:</label>
                                    <input
                                        type="number"
                                        step="0.001"
                                        value={bidValue}
                                        onChange={e => setBidValue(e.target.value)}
                                        placeholder={
                                            auctionType === 0
                                                ? higherBid && minimumBidChangeAmount
                                                    ? `${formatEther(higherBid + minimumBidChangeAmount)} ETH`
                                                    : '0 ETH'
                                                : higherBid
                                                ? `${formatEther(higherBid)} ETH`
                                                : '0 ETH'
                                        }
                                        className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    />
                                    <p className="text-sm text-gray-500 mt-1">≈ ${userBidUsd} USD</p>
                                    <button className="w-full mt-4 px-6 py-3 bg-[#825FAA] hover:bg-[#6d4d8a] active:bg-[#5a3d6f] text-white font-semibold rounded-lg transition-colors duration-200">
                                        Enter the Auction
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Timer Section */}
                    <div className="max-w-2xl mx-auto mt-8 p-6 bg-[linear-gradient(to_left,rgb(147,112,186)_10%,rgb(106,170,142)_90%)] rounded-xl shadow-lg text-white">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {/* Auction Started */}
                            <div className="text-center">
                                <p className="text-sm uppercase tracking-wide opacity-90 mb-2">Auction Started</p>
                                <div className="bg-white/20 backdrop-blur-sm rounded-lg p-3">
                                    <p className="text-lg font-mono">{formatStartDate(startTime)}</p>
                                </div>
                            </div>

                            {/* Time Remaining */}
                            <div className="text-center">
                                <p className="text-sm uppercase tracking-wide opacity-90 mb-2">Time Remaining</p>
                                <div className="bg-white/20 backdrop-blur-sm rounded-lg p-3">
                                    <p
                                        className={`text-2xl font-mono font-bold ${
                                            timeRemaining < 3600 ? 'text-red-300' : ''
                                        }`}
                                    >
                                        {timeRemaining > 0 ? formatTime(timeRemaining) : 'ENDED'}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </>
            ) : (
                <div className="flex items-center justify-center min-h-[50vh]">
                    <div className="text-xl text-gray-600">No active auctions at the moment</div>
                </div>
            )}
        </div>
    );
};

export default CurrentAuction;
