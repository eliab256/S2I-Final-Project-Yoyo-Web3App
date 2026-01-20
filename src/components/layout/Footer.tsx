const Footer: React.FC = () => {
    return (
        <footer className="pt-1 pb-1 sm:pt-2 sm:pb-2 w-full">
            <div className="flex justify-center h-full min-h-0 z-20 lg:mb-0">
                <div className="w-auto">
                    <ul className="list-none p-0 m-0 w-full">
                        <div className="flex flex-col items-center w-full">
                            <div className="flex justify-center items-center gap-1 sm:gap-2 text-xs sm:text-sm md:text-base text-center w-full">
                                <div>
                                    <a
                                        href="https://github.com/eliab256"
                                        target="_blank"
                                        rel="noreferrer"
                                        className="text-[#1a1a1a] no-underline hover:underline"
                                    >
                                        GitHub
                                    </a>
                                </div>
                                <span className="text-[#555]">·</span>
                                <div>
                                    <a
                                        href="https://t.me/Elia_EB"
                                        target="_blank"
                                        rel="noreferrer"
                                        className="text-[#1a1a1a] no-underline hover:underline"
                                    >
                                        Support
                                    </a>
                                </div>
                            </div>

                            <div className="text-xs sm:text-sm md:text-base text-center">
                                <p className="text-xs sm:text-sm md:text-base">
                                    © 2025 Elia Bordoni. All rights reserved.
                                </p>
                            </div>
                        </div>
                    </ul>
                </div>
            </div>
        </footer>
    );
};

export default Footer;
