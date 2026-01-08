import type { AuctionStruct } from '../types/contractsTypes';
import { useDispatch, useSelector } from 'react-redux';
import { resetConfirmPlaceBid } from '../redux/confirmPlaceBidSlice';

interface BidResumeProps {
    bidder: AuctionStruct['higherBidder'];
    bidAmount: AuctionStruct['higherBid'];
}
//serve recuperare se ha nft da claimare

const BidResume: React.FC<BidResumeProps> = ({ bidder, bidAmount }) => {
    const dispatch = useDispatch();

    return (
        <div
            className="fixed inset-0 z-50 flex items-center justify-center"
            onClick={() => dispatch(resetConfirmPlaceBid())}
        >
            <div className="absolute inset-0 bg-black/50"></div>

            <div className="relative w-1/2 h-1/2 bg-white rounded-lg shadow-2xl" onClick={e => e.stopPropagation()}>
                <h2>Bid Resume</h2>
            </div>
        </div>
    );
};

export default BidResume;
