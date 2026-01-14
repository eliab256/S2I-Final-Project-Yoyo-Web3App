import { createSlice, type PayloadAction } from '@reduxjs/toolkit';

interface ClaimRefundState {
    isConfirmed: boolean;
    hash: string | null;
    error: string | null;
    title: string | null;
}

const initialState: ClaimRefundState = {
    isConfirmed: false,
    hash: null,
    error: null,
    title: null,
};

const confirmAndErrorManagerSlice = createSlice({
    name: 'confirmAndErrorManager',
    initialState,
    reducers: {
        setTxConfirmed: (state, action: PayloadAction<{ title: string; hash: string }>) => {
            state.isConfirmed = true;
            state.hash = action.payload.hash;
            state.title = action.payload.title;
            state.error = null;
        },
        setError: (state, action: PayloadAction<{ title: string; error: string }>) => {
            state.error = action.payload.error;
            state.title = action.payload.title;
            state.isConfirmed = false;
            state.hash = null;
        },
        resetConfirmAndErrorManager: state => {
            state.isConfirmed = false;
            state.hash = null;
            state.error = null;
        },
    },
});

export const { setTxConfirmed, setError, resetConfirmAndErrorManager } = confirmAndErrorManagerSlice.actions;
export const selectConfirmAndErrorManager = (state: { confirmAndErrorManager: ClaimRefundState }) =>
    state.confirmAndErrorManager;
export const confirmAndErrorManagerReducer = confirmAndErrorManagerSlice.reducer;
