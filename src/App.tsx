import Header from './components/Header';
import Gallery from './components/Gallery';
import CurrentAuction from './components/CurrentAuction';
import MyNfts from './components/MyNfts';
import AboutUs from './components/AboutUs';
import Footer from './components/Footer';
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
