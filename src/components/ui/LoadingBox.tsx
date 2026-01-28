interface LoadingBoxProps {
    title: string;
    message: string;
}

const LoadingBox: React.FC<LoadingBoxProps> = ({ title, message }) => {
    return (
        <div className="relative flex justify-center items-center min-h-[50vh] px-4">
            <div className="bg-white rounded-2xl shadow-lg p-6 w-full max-w-md text-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4 mx-auto"></div>
                <h2 className="text-xl md:text-2xl font-semibold text-gray-700 mb-2">{title}</h2>
                <p className="text-gray-600">{message}</p>
            </div>
        </div>
    );
};

export default LoadingBox;
