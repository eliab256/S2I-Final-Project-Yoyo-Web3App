import Header from './components/Header';
import Gallery from './components/Gallery';
import CurrentAuction from './components/CurrentAuction';
import MyNfts from './components/MyNfts';
import AboutUs from './components/AboutUs';
import Footer from './components/Footer';
import { useSelector, useDispatch } from 'react-redux';
import { type PageState } from './redux/pagesSlice';
import { resetConfirmedTxManager, selectConfirmedTxManager } from './redux/confirmedTxManagerSlice';
import { resetErrorManager, selectErrorManager } from './redux/errorManagerSlice';
import SuccessBox from './components/SuccessBox';
import WarningBox from './components/WarningBox';

function App() {
    const dispatch = useDispatch();
    const currentOpenPage = useSelector(
        (state: { currentPage: { currentPage: PageState } }) => state.currentPage.currentPage
    );
    const {
        isConfirmed,
        hash,
        title: TxConfirmTitle,
        message: TxConfirmMessage,
    } = useSelector(selectConfirmedTxManager);
    const { error, title: errorTitle } = useSelector(selectErrorManager);

    const pageComponents = {
        gallery: <Gallery />,
        currentAuction: <CurrentAuction />,
        myNfts: <MyNfts />,
        aboutUs: <AboutUs />,
    };

    return (
        <>
            <Header />
            <main className="relative w-full">
                {pageComponents[currentOpenPage]}
                {isConfirmed && (
                    <SuccessBox
                        title={TxConfirmTitle || "Success"}
                        message={TxConfirmMessage || "Transaction confirmed successfully."}
                        txHash={hash || ""}
                        onClose={() => dispatch(resetConfirmedTxManager())}
                    ></SuccessBox>
                )}
                {error && (
                    <WarningBox title={errorTitle || "Error"} message={error} onClose={() => dispatch(resetErrorManager())} />
                    //check se effettivamente può essere non usato onClose
                )}
            </main>
            <Footer />
        </>
    );
}

export default App;
