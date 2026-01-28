import { XMarkIcon } from '@heroicons/react/24/solid';

interface ErrorBoxProps {
    title: string;
    message: string;
    onClose?: () => void;
}

const ErrorBox: React.FC<ErrorBoxProps> = ({ title, message, onClose }) => {
    console.log(`${title} Error :`, message);

    // When onClose is provided, render a modal with overlay
    if (onClose) {
        return (
            <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/20" onClick={onClose}>
                <div className="relative animate-pulse" onClick={e => e.stopPropagation()}>
                    <div className="border-red-500 border-2 bg-white rounded-2xl shadow-lg p-6 w-full max-w-md text-center">
                        {/* Close Button */}
                        <button
                            className="absolute top-3 right-3 bg-red-500 rounded-full active:scale-95 active:bg-red-600 
                            transition-transform duration-150 shadow-md cursor-pointer p-2"
                            onClick={onClose}
                        >
                            <XMarkIcon className="h-4 w-4 text-white" />
                        </button>

                        <h2 className="text-xl md:text-2xl font-semibold text-red-700 mb-2">{title}</h2>
                        <p className="text-red-600">{'Check console for more details.'}</p>
                    </div>
                </div>
            </div>
        );
    }

    // When onClose is not provided, render a simple box
    return (
        <div className="mx-auto my-8 max-w-md px-4">
            <div className="relative border-red-500 border-2 bg-white rounded-2xl shadow-lg p-6 text-center animate-pulse">
                <h2 className="text-xl md:text-2xl font-semibold text-red-700 mb-2">{title}</h2>
                <p className="text-red-600">{'Check console for more details.'}</p>
            </div>
        </div>
    );
};

export default ErrorBox;
