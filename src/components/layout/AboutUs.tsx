import logoImage from '../../assets/images/Yoyo-Logo-Scritta-Scura.png';

const AboutUs: React.FC = () => {
    return (
        <div className="flex flex-col items-center text-center w-full px-4 sm:px-8 md:px-16 lg:px-32">
            <div className="h-auto sm:h-[calc(100vh-var(--headerAndFooterHeight))] flex justify-center pt-8 pb-8 sm:pt-12 md:pt-20 sm:pb-12 md:pb-20">
                <img
                    src={logoImage}
                    alt="yoyo logo image"
                    className="max-w-full h-auto max-h-64 sm:max-h-48 md:max-h-none"
                />
            </div>

            <div className="px-2 sm:px-4">
                <h1 className="m-2 sm:m-4">About Us</h1>
                <div>
                    <h3 className="m-2 sm:m-4">Who We Are</h3>
                    <p className="text-sm sm:text-base md:text-lg lg:text-[1.5vw] text-justify leading-relaxed mb-6 sm:mb-12">
                        YoYo is an inclusive yoga platform created from a personal journey — inspired by the founder' s
                        sister, who faced permanent mobility challenges after an accident. What began as a search for
                        accessible movement has grown into a mission to make yoga truly available to everyone. With the
                        help of yoga teachers, physiotherapists, and wellness experts, YoYo offers personalized programs
                        tailored to each user's physical needs. Whether you're a beginner, pregnant, using prosthetics,
                        or dealing with mobility issues, YoYo adapts to you.
                    </p>
                </div>
                <div>
                    <div></div>
                    <div>
                        <h3 className="m-2 sm:m-4">Practice Yoga, Your Way</h3>
                        <p className="text-sm sm:text-base md:text-lg lg:text-[1.5vw] text-justify leading-relaxed mb-6 sm:mb-12">
                            A yoga experience designed to adapt to your body and your needs. YoYo lets you personalize
                            your practice by considering mobility limitations, temporary conditions, or personal goals,
                            offering guided paths created by yoga instructors and healthcare professionals to ensure
                            safety, comfort, and balance in every session.
                        </p>
                    </div>
                </div>

                <div>
                    <div></div>
                    <div>
                        <h3 className="m-2 sm:m-4">Inclusive By Design, Empowering By Nature</h3>
                        <p className="text-sm sm:text-base md:text-lg lg:text-[1.5vw] text-justify leading-relaxed mb-6 sm:mb-12">
                            YoYo believes yoga should be accessible to everyone, not just a few. Through adaptive
                            exercises, community challenges, and innovative digital tools, the platform removes physical
                            and mental barriers, helping people reconnect with their bodies, improve well-being, and
                            feel supported at every stage of their journey.
                        </p>
                    </div>
                </div>
                <div>
                    <h3 className="m-2 sm:m-4">Powered by Web3 Technology</h3>
                    <p className="text-sm sm:text-base md:text-lg lg:text-[1.5vw] text-justify leading-relaxed mb-6 sm:mb-12">
                        To push the experience further, YoYo integrates NFT technology, allowing users to unlock
                        exclusive content, redeem rewards, and join themed events, making the practice of yoga more
                        connected, inclusive, and future-ready. Both the auctions and the NFTs of Yoyo are managed by
                        Solidity smart contracts deployed on the Ethereum Sepolia testnet. All functions have been
                        tested to allow each user to place bids, win, and transfer their own NFTs. The web interface
                        enables users to interact with the contracts easily and in a user-friendly way, while
                        maintaining the level of security guaranteed by the blockchain.
                    </p>
                </div>
            </div>
        </div>
    );
};

export default AboutUs;
