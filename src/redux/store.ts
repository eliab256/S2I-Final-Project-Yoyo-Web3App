import { configureStore } from '@reduxjs/toolkit';
import { currentPageReducer } from './pagesSlice';
import { selectedNftReducer } from './selectedNftSlice';
import { confirmPlaceBidReducer } from './confirmPlaceBidSlice';
import { confirmedTxManagerReducer } from './confirmedTxManagerSlice';
import { errorManagerReducer } from './errorManagerSlice';

const store = configureStore({
    reducer: {
        currentPage: currentPageReducer,
        selectedNft: selectedNftReducer,
        confirmPlaceBid: confirmPlaceBidReducer,
        confirmedTxManager: confirmedTxManagerReducer,
        errorManager: errorManagerReducer,
    },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export default store;
