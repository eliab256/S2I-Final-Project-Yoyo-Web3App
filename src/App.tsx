import Header from './components/layout/Header';
import Gallery from './components/layout/Gallery';
import CurrentAuction from './components/layout/CurrentAuction';
import MyNfts from './components/layout/MyNfts';
import AboutUs from './components/layout/AboutUs';
import Footer from './components/layout/Footer';
import { useSelector } from 'react-redux';
import { type PageState } from './redux/pagesSlice';

function App() {
    const currentOpenPage = useSelector(
        (state: { currentPage: { currentPage: PageState } }) => state.currentPage.currentPage
    );

    const pageComponents = {
        gallery: <Gallery />,
        currentAuction: <CurrentAuction />,
        myNfts: <MyNfts />,
        aboutUs: <AboutUs />,
    };

    return (
        <>
            <Header />
            <main className="relative w-full">{pageComponents[currentOpenPage]}</main>
            <Footer />
        </>
    );
}

export default App;
