import { createSlice, type PayloadAction } from '@reduxjs/toolkit';
import type { RootState } from './store';
import type { PageState } from '../types/pageTypes';    



interface CurrentPageState {
    currentPage: PageState;
}

const initialState: CurrentPageState = {
    currentPage: 'gallery',
};

export const currentPageSlice = createSlice({
    name: 'currentPage',
    initialState,
    reducers: {
        setCurrentPage: (state, action: PayloadAction<PageState>) => {
            state.currentPage = action.payload;
        },
    },
});

//Actions
export const { setCurrentPage } = currentPageSlice.actions;

//Selectors
export const selectCurrentPage = (state: RootState) => state.currentPage.currentPage;

//Reducer
export const currentPageReducer = currentPageSlice.reducer;


