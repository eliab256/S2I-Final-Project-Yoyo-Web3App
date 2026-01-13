import { clearSelectedNft } from '../redux/selectedNftSlice';
import { XMarkIcon, CheckCircleIcon, XCircleIcon } from '@heroicons/react/24/solid';
import { useDispatch } from 'react-redux';
import type { NftData } from '../types/nftTypes';

const NftDetails: React.FC<NftData> = ({ metadata, tokenId, image }) => {
    const dispatch = useDispatch();
    // Metadata deconstruction
    const { name, description, attributes, properties } = metadata;

    // Properties deconstruction
    const { category, course_type, accessibility_level, redeemable, instructor_certified, style } = properties;

    return (
        <div
            className="relative flex flex-col items-center rounded-xl bg-white/95 backdrop-blur-sm
            p-2 sm:p-3 md:p-4 lg:p-10 w-[95%] sm:w-[90%] md:w-4/5 lg:w-1/2 mx-auto my-3 sm:my-4 md:my-5 lg:my-6
            border border-gray-300 shadow-lg min-h-[calc(100vh-48px)] max-h-[100vh] overflow-y-auto cursor-default"
        >
            {/* Close Button */}
            <div
                className="absolute top-3 right-3 bg-red-500 rounded-full active:scale-95 active:bg-red-600 
                transition-transform duration-150 shadow-md cursor-pointer p-2"
                onClick={() => dispatch(clearSelectedNft())}
            >
                <XMarkIcon className="h-4 w-4 text-white" />
            </div>
            {/* Title */}
            <div className="flex flex-col items-center w-full mb-1 md:mb-4">
                <h2 className="text-xl sm:text-2xl md:text-3xl lg:text-4xl font-bold text-center">{name}</h2>
            </div>

            {/* Image */}
            <div className="flex flex-col items-center w-full mb-4 pt-4 sm:pt-6">
                <img
                    src={image}
                    alt={name}
                    className="w-full max-w-[180px] sm:max-w-[220px] md:max-w-[260px] lg:max-w-[220px] xl:max-w-[300px] h-auto object-cover rounded-md"
                />
            </div>

            {/* Description */}
            <div className="flex flex-col items-center w-full mb-2 px-4 sm:px-6 md:px-8 text-xs sm:text-base md:text-lg">
                <p className="text-gray-600 text-justify">{description}</p>
            </div>

            {/* Token ID */}
            <div className="w-full px-4 sm:px-6 md:px-8 mb-4">
                <div className="bg-gradient-to-r from-purple-50 to-pink-50 rounded-lg p-3 border border-purple-200">
                    <p className="text-sm sm:text-base font-semibold text-purple-900">
                        Token ID: <span className="text-purple-600">#{tokenId}</span>
                    </p>
                </div>
            </div>

            {/* Properties Section */}
            <div className="w-full px-4 sm:px-6 md:px-8 mb-4">
                <h3 className="text-lg sm:text-xl md:text-2xl font-bold mb-3 text-gray-800">Course Properties</h3>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    {/* Category */}
                    <div className="bg-blue-50 rounded-lg p-3 border border-blue-200">
                        <p className="text-xs text-blue-600 font-semibold mb-1">Category</p>
                        <p className="text-sm sm:text-base text-blue-900 font-medium">{category}</p>
                    </div>

                    {/* Course Type */}
                    <div className="bg-green-50 rounded-lg p-3 border border-green-200">
                        <p className="text-xs text-green-600 font-semibold mb-1">Course Type</p>
                        <p className="text-sm sm:text-base text-green-900 font-medium">{course_type}</p>
                    </div>

                    {/* Accessibility Level */}
                    <div className="bg-yellow-50 rounded-lg p-3 border border-yellow-200">
                        <p className="text-xs text-yellow-600 font-semibold mb-1">Accessibility Level</p>
                        <p className="text-sm sm:text-base text-yellow-900 font-medium">{accessibility_level}</p>
                    </div>

                    {/* Style */}
                    <div className="bg-pink-50 rounded-lg p-3 border border-pink-200">
                        <p className="text-xs text-pink-600 font-semibold mb-1">Style</p>
                        <p className="text-sm sm:text-base text-pink-900 font-medium">{style}</p>
                    </div>

                    {/* Redeemable */}
                    <div className="bg-purple-50 rounded-lg p-3 border border-purple-200 flex items-center justify-between">
                        <div>
                            <p className="text-xs text-purple-600 font-semibold mb-1">Redeemable</p>
                            <p className="text-sm sm:text-base text-purple-900 font-medium">
                                {redeemable ? 'Yes' : 'No'}
                            </p>
                        </div>
                        {redeemable ? (
                            <CheckCircleIcon className="h-6 w-6 text-green-500" />
                        ) : (
                            <XCircleIcon className="h-6 w-6 text-red-500" />
                        )}
                    </div>

                    {/* Instructor Certified */}
                    <div className="bg-indigo-50 rounded-lg p-3 border border-indigo-200 flex items-center justify-between">
                        <div>
                            <p className="text-xs text-indigo-600 font-semibold mb-1">Instructor Certified</p>
                            <p className="text-sm sm:text-base text-indigo-900 font-medium">
                                {instructor_certified ? 'Yes' : 'No'}
                            </p>
                        </div>
                        {instructor_certified ? (
                            <CheckCircleIcon className="h-6 w-6 text-green-500" />
                        ) : (
                            <XCircleIcon className="h-6 w-6 text-red-500" />
                        )}
                    </div>
                </div>
            </div>

            {/* Attributes Section */}
            <div className="w-full px-4 sm:px-6 md:px-8 mb-4">
                <h3 className="text-lg sm:text-xl md:text-2xl font-bold mb-3 text-gray-800">Attributes</h3>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
                    {attributes.map((attr, index) => (
                        <div
                            key={index}
                            className="bg-gradient-to-br from-gray-50 to-gray-100 rounded-lg p-3 border border-gray-200 hover:shadow-md transition-shadow"
                        >
                            <p className="text-xs text-gray-500 font-semibold mb-1 truncate" title={attr.trait_type}>
                                {attr.trait_type}
                            </p>
                            <p
                                className="text-sm sm:text-base text-gray-900 font-bold truncate"
                                title={String(attr.value)}
                            >
                                {attr.value}
                            </p>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};
export default NftDetails;
