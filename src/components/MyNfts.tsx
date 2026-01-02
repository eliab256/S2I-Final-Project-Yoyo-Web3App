import { useAccount } from 'wagmi';

const MyNfts: React.FC = () => {
    const { isConnected } = useAccount();
    return (
        <div className="w-full lg:min-h-[calc(100vh-var(--headerAndFooterHeight)*2)]">
            <div className="px-2 sm:px-4 text-center">
                <h1>My Nfts</h1>
            </div>
            <div>
                {/* wallet is not connected */}
                {!isConnected && (
                    <div className="relative flex justify-center items-center min-h-[50vh] px-4 animate-pulse ">
                        <div className="border-red-500 border-2 bg-white  rounded-2xl shadow-lg p-6 w-full max-w-md text-center">
                            <h2 className="text-xl md:text-2xl font-semibold text-red-700 mb-2">
                                Wallet not connected
                            </h2>
                            <p className="text-red-600">Please connect your wallet to view your products.</p>
                        </div>
                    </div>
                )}
                 {/* wallet is connected but the user hasn't never bought a product
                {isConnected && address && !hasPurchased && !loading && (
                    <div className="relative flex justify-center items-center min-h-[50vh] px-4 animate-pulse ">
                        <div className="border-red-500 border-2 bg-white  rounded-2xl shadow-lg p-6 w-full max-w-md text-center">
                            <h2 className="text-xl md:text-2xl font-semibold text-red-700 mb-2">
                                You don't hold any NFTs yet
                            </h2>
                            <p className="text-red-600">Go to the auction page and place a bid to win your first NFT.</p>
                        </div>
                    </div>
                )} */}
            </div>
        </div>
    );
};

export default MyNfts;
