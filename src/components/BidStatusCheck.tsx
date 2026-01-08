interface BidStatusCheckProps {
    isValid: boolean;
    validMessage: string;
    invalidMessage: string;
    additionalInfo?: string;
    icon?: {
        valid: React.ReactNode;
        invalid: string;
    };
    delay?: number;
}

const BidStatusCheck: React.FC<BidStatusCheckProps> = ({
    isValid,
    validMessage,
    invalidMessage,
    additionalInfo,
    icon = { valid: '✅', invalid: '❌' },
    delay = 0,
}) => {
    return (
        <div
            className={`flex items-center gap-3 p-3 rounded-lg animate-[slideIn_0.5s_ease-out_forwards] opacity-0 ${
                isValid ? 'bg-green-50' : 'bg-red-50'
            }`}
            style={{ animationDelay: `${delay}s` }}
        >
            <span className="text-2xl">{isValid ? icon.valid : icon.invalid}</span>
            <div>
                <p className={`font-semibold ${isValid ? 'text-green-700' : 'text-red-700'}`}>
                    {isValid ? validMessage : invalidMessage}
                </p>
                {additionalInfo && <p className="text-sm text-gray-600">{additionalInfo}</p>}
            </div>
        </div>
    );
};

export default BidStatusCheck;
