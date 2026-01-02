import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useDispatch } from 'react-redux';
import { setCurrentPage } from '../redux/pagesSlice';
import logoImage from '../assets/images/Yoyo-Logo-Scritta-Scura.png';
import { useState } from 'react';

const Header: React.FC = () => {
    const dispatch = useDispatch();
    const [isMenuOpen, setIsMenuOpen] = useState(false);

    const handleLogoClick = () => {
        // Su mobile toggle del menu, su desktop vai alla gallery
        const isMobile = window.innerWidth < 640;
        if (isMobile) {
            setIsMenuOpen(!isMenuOpen);
        } else {
            dispatch(setCurrentPage('gallery'));
        }
    };

    const handlePageChange = (page: 'gallery' | 'currentAuction' | 'myNfts' | 'aboutUs') => {
        dispatch(setCurrentPage(page));
        setIsMenuOpen(false);
    };

    return (
        <header className="p-1 sm:p-2 h-[var(--headerAndFooterHeight)] flex justify-between fixed top-0 left-0 w-full shadow-md z-50 px-2 sm:px-4 bg-white">
            <div className="h-full flex items-center gap-0.5 sm:gap-1 relative">
                <div
                    onClick={handleLogoClick}
                    role="button"
                    className="flex items-center justify-center h-full cursor-pointer mr-1 sm:mr-2"
                >
                    <img src={logoImage} alt="yoyo logo image" className="h-full" />
                </div>

                {/* Mobile dropdown menu */}
                {isMenuOpen && (
                    <div className="absolute top-full left-0 mt-1 bg-white shadow-lg rounded-lg py-2 min-w-[150px] sm:hidden z-50">
                        <button
                            onClick={() => handlePageChange('currentAuction')}
                            className="w-full px-4 py-2 text-left hover:shadow-[0_0_10px_rgba(106,170,142,0.5)] transition-shadow font-['Amatic_SC',_cursive] text-lg rounded"
                        >
                            Auction
                        </button>
                        <button
                            onClick={() => handlePageChange('myNfts')}
                            className="w-full px-4 py-2 text-left hover:shadow-[0_0_10px_rgba(106,170,142,0.5)] transition-shadow font-['Amatic_SC',_cursive] text-lg rounded"
                        >
                            My NFTs
                        </button>
                        <button
                            onClick={() => handlePageChange('aboutUs')}
                            className="w-full px-4 py-2 text-left hover:shadow-[0_0_10px_rgba(106,170,142,0.5)] transition-shadow font-['Amatic_SC',_cursive] text-lg rounded"
                        >
                            About Us
                        </button>
                    </div>
                )}

                {/* Desktop navigation buttons - hidden on mobile */}
                <div className="hidden sm:flex items-center justify-center h-full w-16 md:w-20 mr-0.5 md:mr-1">
                    <button
                        onClick={() => handlePageChange('currentAuction')}
                        className="relative h-full w-full cursor-pointer bg-transparent border-none rounded-[30px] font-['Amatic_SC',_cursive] text-lg md:text-[25px] hover:bg-[var(--thirdGreen)] hover:text-white transition-colors duration-200 before:content-[''] before:absolute before:w-0 before:h-[0.2em] before:bg-gradient-to-r before:from-[var(--mainPurple)] before:to-white before:bottom-[0.3rem] before:transition-all before:duration-400 before:rounded-[30px] before:left-1/2 before:-translate-x-1/2 hover:before:w-[70%]"
                    >
                        Auction
                    </button>
                </div>
                <div className="hidden sm:flex items-center justify-center h-full w-16 md:w-20 mr-0.5 md:mr-1">
                    <button
                        onClick={() => handlePageChange('myNfts')}
                        className="relative h-full w-full cursor-pointer bg-transparent border-none rounded-[30px] font-['Amatic_SC',_cursive] text-lg md:text-[25px] hover:bg-[var(--thirdGreen)] hover:text-white transition-colors duration-200 before:content-[''] before:absolute before:w-0 before:h-[0.2em] before:bg-gradient-to-r before:from-[var(--mainPurple)] before:to-white before:bottom-[0.3rem] before:transition-all before:duration-400 before:rounded-[30px] before:left-1/2 before:-translate-x-1/2 hover:before:w-[70%]"
                    >
                        My NFTs
                    </button>
                </div>
                <div className="hidden sm:flex items-center justify-center h-full w-16 md:w-20 mr-0.5 md:mr-1">
                    <button
                        onClick={() => handlePageChange('aboutUs')}
                        className="relative h-full w-full cursor-pointer bg-transparent border-none rounded-[30px] font-['Amatic_SC',_cursive] text-lg md:text-[25px] hover:bg-[var(--thirdGreen)] hover:text-white transition-colors duration-200 before:content-[''] before:absolute before:w-0 before:h-[0.2em] before:bg-gradient-to-r before:from-[var(--mainPurple)] before:to-white before:bottom-[0.3rem] before:transition-all before:duration-400 before:rounded-[30px] before:left-1/2 before:-translate-x-1/2 hover:before:w-[70%]"
                    >
                        About Us
                    </button>
                </div>
            </div>

            <div className="flex items-center justify-center">
                <ConnectButton
                    accountStatus={{
                        smallScreen: 'avatar',
                        largeScreen: 'full',
                    }}
                    showBalance={{
                        smallScreen: false,
                        largeScreen: true,
                    }}
                />
            </div>
        </header>
    );
};

export default Header;
