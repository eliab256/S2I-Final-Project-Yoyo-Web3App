import logoImage from '../../assets/images/Yoyo-Logo-Scritta-Scura.png';

const AboutUs: React.FC = () => {
    return (
        <div className="flex flex-col items-center text-center w-full">
            <div className="h-auto sm:h-[calc(100vh-var(--headerAndFooterHeight))] flex justify-center pt-8 pb-8 sm:pt-12 md:pt-20 sm:pb-12 md:pb-20">
                <img
                    src={logoImage}
                    alt="yoyo logo image"
                    className="max-w-full h-auto max-h-64 sm:max-h-48 md:max-h-none"
                />
            </div>
            <div className="px-2 sm:px-4">
                <h1 className="m-2 sm:m-4">About Us</h1>
                <p className="text-sm sm:text-base md:text-lg lg:text-[2vw] text-justify leading-relaxed mb-6 sm:mb-12">
                    YoYo is an inclusive yoga platform created from a personal journey — inspired by the founder' s
                    sister, who faced permanent mobility challenges after an accident. What began as a search for
                    accessible movement has grown into a mission to make yoga truly available to everyone. With the help
                    of yoga teachers, physiotherapists, and wellness experts, YoYo offers personalized programs tailored
                    to each user's physical needs. Whether you're a beginner, pregnant, using prosthetics, or dealing
                    with mobility issues, YoYo adapts to you. To push the experience further, YoYo integrates NFT
                    technology, allowing users to unlock exclusive content, redeem rewards, and join themed events —
                    making the practice of yoga more connected, inclusive, and future-ready.
                </p>
            </div>
        </div>
    );
};

export default AboutUs;
