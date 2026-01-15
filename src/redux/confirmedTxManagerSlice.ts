import { createSlice, type PayloadAction } from '@reduxjs/toolkit';

interface ConfirmedTxState {
    isConfirmed: boolean;
    hash: string | null;
    title: string | null;
    message: string | null;
}

const initialState: ConfirmedTxState = {
    isConfirmed: false,
    hash: null,
    title: null,
    message: null,
};

const confirmedTxManagerSlice = createSlice({
    name: 'confirmedTxManager',
    initialState,
    reducers: {
        setConfirmedTxManager: (state, action: PayloadAction<{ title: string; hash: string; message: string }>) => {
            state.isConfirmed = true;
            state.hash = action.payload.hash;
            state.title = action.payload.title;
            state.message = action.payload.message;
        },

        resetConfirmedTxManager: state => {
            state.isConfirmed = false;
            state.hash = null;
            state.message = null;
            state.title = null;
        },
    },
});

export const { setConfirmedTxManager, resetConfirmedTxManager } = confirmedTxManagerSlice.actions;
export const selectConfirmedTxManager = (state: { confirmedTxManager: ConfirmedTxState }) => state.confirmedTxManager;
export const confirmedTxManagerReducer = confirmedTxManagerSlice.reducer;
