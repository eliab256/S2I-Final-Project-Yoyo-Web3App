interface SuccessBoxProps {
    title: string;
    message: string;
    txHash: string;
    onClose?: () => void;
}

const SuccessBox: React.FC<SuccessBoxProps> = ({ title, message, txHash, onClose }) => {
        const handleBackdropClick = () => {
        if (onClose) {
            onClose();
        }
    };
    const etherscanLink = txHash ? `https://sepolia.etherscan.io/tx/${txHash}` : null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center" onClick={handleBackdropClick}>
            <div className="absolute inset-0 bg-black/50"></div>
            <div
                className="relative border-green-500 border-2 bg-white rounded-2xl shadow-lg p-6 w-full max-w-md text-center"
                onClick={e => e.stopPropagation()}
            >
                <div className="mb-4">
                    <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                        <span className="text-4xl">✅</span>
                    </div>
                    <h2 className="text-xl md:text-2xl font-semibold text-green-700 mb-2">{title}</h2>
                    <p className="text-green-600 mb-4">{message}</p>
                </div>

                {etherscanLink && (
                    <a
                        href={etherscanLink}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-block px-6 py-3 bg-green-600 hover:bg-green-700 text-white font-semibold rounded-lg transition-colors duration-200 mb-4"
                    >
                        View on Etherscan ↗
                    </a>
                )}
            </div>
        </div>
    );
};

export default SuccessBox;
