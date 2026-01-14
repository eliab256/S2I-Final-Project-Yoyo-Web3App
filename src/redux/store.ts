import { configureStore } from '@reduxjs/toolkit';
import { currentPageReducer } from './pagesSlice';
import { selectedNftReducer } from './selectedNftSlice';
import { confirmPlaceBidReducer } from './confirmPlaceBidSlice';
import { confirmAndErrorManagerReducer } from './confirmAndErrorManagerSlice';

const store = configureStore({
    reducer: {
        currentPage: currentPageReducer,
        selectedNft: selectedNftReducer,
        confirmPlaceBid: confirmPlaceBidReducer,
        confirmAndErrorManager: confirmAndErrorManagerReducer,
    },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export default store;
