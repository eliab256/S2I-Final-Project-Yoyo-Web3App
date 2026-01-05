import { configureStore } from '@reduxjs/toolkit';
import { currentPageReducer } from './pagesSlice';
import { selectedNftReducer } from './selectedNftSlice';

const store = configureStore({
    reducer: {
        currentPage: currentPageReducer,
        selectedNft: selectedNftReducer,
    },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export default store;
