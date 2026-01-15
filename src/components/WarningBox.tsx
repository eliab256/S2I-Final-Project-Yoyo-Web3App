import { XMarkIcon } from '@heroicons/react/24/solid';

interface WarningBoxProps {
    title: string;
    message: string;
    onClose?: () => void;
}

const WarningBox: React.FC<WarningBoxProps> = ({ title, message, onClose }) => {
    const handleBackdropClick = () => {
        if (onClose) {
            onClose();
        }
    };
    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
            {/* <div className="absolute inset-0 bg-white/50"></div> */}
            <div
                className="relative flex justify-center items-center min-h-[50vh] px-4 animate-pulse"
                onClick={e => e.stopPropagation()}
            >
                <div className="border-red-500 border-2 bg-white rounded-2xl shadow-lg p-6 w-full max-w-md text-center">
                    {/* Close Button - visible only if onClose is present */}
                    {onClose && (
                        <div
                            className="absolute top-3 right-3 bg-red-500 rounded-full active:scale-95 active:bg-red-600 
                        transition-transform duration-150 shadow-md cursor-pointer p-2"
                            onClick={handleBackdropClick}
                        >
                            <XMarkIcon className="h-4 w-4 text-white" />
                        </div>
                    )}
                    <h2 className="text-xl md:text-2xl font-semibold text-red-700 mb-2">{title}</h2>
                    <p className="text-red-600">{message}</p>
                </div>
            </div>
        </div>
    );
};

export default WarningBox;
