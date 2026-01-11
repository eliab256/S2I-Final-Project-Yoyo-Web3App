import Header from './components/Header';
import Gallery from './components/Gallery';
import CurrentAuction from './components/CurrentAuction';
import MyNfts from './components/MyNfts';
import AboutUs from './components/AboutUs';
import Footer from './components/Footer';
import { useSelector } from 'react-redux';
import { type PageState } from './redux/pagesSlice';
import { useRefundNotifications } from './hooks/useRefundNotifications';
import RefundNotificationPopup from './components/RefundNotificationPopup';

function App() {
    const currentOpenPage = useSelector(
        (state: { currentPage: { currentPage: PageState } }) => state.currentPage.currentPage
    );

    const { pendingRefund, dismissRefund } = useRefundNotifications();

    const pageComponents = {
        gallery: <Gallery />,
        currentAuction: <CurrentAuction />,
        myNfts: <MyNfts />,
        aboutUs: <AboutUs />,
    };

    return (
        <>
            <Header />
            <main className="relative">
                {pageComponents[currentOpenPage]}
                <RefundNotificationPopup refund={pendingRefund} onDismiss={dismissRefund} />
            </main>
            <Footer />
        </>
    );
}

export default App;
