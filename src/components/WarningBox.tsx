interface WarningBoxProps {
    title: string;
    message: string;
}

const WarningBox: React.FC<WarningBoxProps> = ({ title, message }) => {
    return (
        <>
            <div className="absolute inset-0 bg-black/50"></div>
            <div
                className="relative border-yellow-500 border-2 bg-white rounded-2xl shadow-lg p-6 w-full max-w-md text-center"
                onClick={e => e.stopPropagation()}
            >
                <div className="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-4xl">ℹ️</span>
                </div>
                <h2 className="text-xl md:text-2xl font-semibold text-yellow-700 mb-2">{title}</h2>
                <p className="text-yellow-600 mb-4">{message}</p>
            </div>
        </>
    );
};
export default WarningBox;
