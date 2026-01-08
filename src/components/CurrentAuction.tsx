import useCurrentAuction from '../hooks/useCurrentAuction';
import NftCard from './NftCard';
import CountDown from './CountDown';
import BidResume from './BidResume';
import { formatEther } from 'viem';
import { useMemo, useState } from 'react';
import useEthereumPrice from '../hooks/useEthereumPrice';
import { useDispatch, useSelector } from 'react-redux';
import { setIsConfirmBidPanelOpen } from '../redux/confirmPlaceBidSlice';
import { useAccount } from 'wagmi';

const CurrentAuction: React.FC = () => {
    const {  isConnected } = useAccount();
    const { auction, isLoading } = useCurrentAuction();
    const { price: ethPriceUSD } = useEthereumPrice();
    const [bidValue, setBidValue] = useState<string>('');
    const openConfirmPanel = useSelector(
        (state: { confirmPlaceBid: { isConfirmBidPanelOpen: boolean } }) => state.confirmPlaceBid.isConfirmBidPanelOpen
    );
    const dispatch = useDispatch();

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

    // Calcola il bid minimo richiesto
    const minimumRequiredBid = useMemo(() => {
        if (!auction) return 0;

        if (auction.auctionType === 0) {
            // English auction: higher bid + minimum increment
            return auction.higherBid && auction.minimumBidChangeAmount
                ? parseFloat(formatEther(auction.higherBid + auction.minimumBidChangeAmount))
                : 0;
        } else {
            // Dutch auction: current price
            return auction.higherBid ? parseFloat(formatEther(auction.higherBid)) : 0;
        }
    }, [auction]);

    // Verifica se il bid inserito è valido
    const isBidValid = useMemo(() => {
        if (!bidValue) return false;
        const numericBid = parseFloat(bidValue);
        if (isNaN(numericBid)) return false;
        if (!auction?.endTime) return false;
        const now = Math.floor(Date.now() / 1000);
        if (Number(auction.endTime) <= now) return false;
        return numericBid >= minimumRequiredBid;
    }, [bidValue, minimumRequiredBid, auction?.endTime]);

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

    return (
        <div className="w-full px-2 sm:px-4 lg:min-h-[calc(100vh-var(--headerAndFooterHeight)*2)]">
            <h1 className="text-center">Current Auction</h1>
            {isLoading ? (
                <div className="flex items-center justify-center min-h-[50vh]">
                    <div className="text-xl">Loading current auction...</div>
                </div>
            ) : tokenId !== undefined ? (
                <>
                    <h2 className="text-center">Auction ID: {auctionId}</h2>
                    <div className="flex flex-col lg:flex-row gap-4 items-start justify-center mt-3">
                        <NftCard tokenId={Number(tokenId)} />
                        <div className="max-w-md w-full p-4 bg-white rounded-xl shadow-lg">
                            <h2 className="text-2xl font-bold text-center mb-2">Place Your Bid Here</h2>
                            <p className="text-lg text-center mb-3 w-full">
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
                                        onClick={() => {
                                            if (!bidValue) {
                                                setBidValue(minimumRequiredBid.toString());
                                            }
                                        }}
                                        placeholder={
                                            auctionType === 0
                                                ? higherBid && minimumBidChangeAmount
                                                    ? `${formatEther(higherBid + minimumBidChangeAmount)} ETH`
                                                    : '0 ETH'
                                                : higherBid
                                                ? `${formatEther(higherBid)} ETH`
                                                : '0 ETH'
                                        }
                                        className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer"
                                    />
                                    <p className="text-sm text-gray-500 mt-1">≈ ${userBidUsd} USD</p>
                                    <button
                                        className="w-full mt-4 px-6 py-3 bg-[#825FAA] hover:bg-[#6d4d8a] active:bg-[#5a3d6f] text-white font-semibold rounded-lg transition-colors duration-200 cursor-pointer disabled:bg-gray-400 disabled:cursor-not-allowed disabled:hover:bg-gray-400"
                                        onClick={() => dispatch(setIsConfirmBidPanelOpen())}
                                        disabled={!isBidValid || !isConnected}
                                    >
                                        Enter the Auction
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <CountDown startTime={startTime} endTime={endTime} />
                    {openConfirmPanel && <BidResume bidAmount={bidValue} />}
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
