interface WarningBoxProps {
    title: string;
    message: string;
}

const WarningBox: React.FC<WarningBoxProps> = ({ title, message }) => {
    return (
        <div className="relative flex justify-center items-center min-h-[50vh] px-4 animate-pulse">
            <div className="border-red-500 border-2 bg-white rounded-2xl shadow-lg p-6 w-full max-w-md text-center">
                <h2 className="text-xl md:text-2xl font-semibold text-red-700 mb-2">{title}</h2>
                <p className="text-red-600">{message}</p>
            </div>
        </div>
    );
};

export default WarningBox;