import { createSlice, type PayloadAction } from '@reduxjs/toolkit';

interface ErrorTxState {
    error: string | null;
    title: string | null;
}

const initialState: ErrorTxState = {
    error: null,
    title: null,
};

const errorManagerSlice = createSlice({
    name: 'errorManager',
    initialState,
    reducers: {
        setError: (state, action: PayloadAction<{ title: string; error: string }>) => {
            state.error = action.payload.error;
            state.title = action.payload.title;
        },
        resetErrorManager: state => {
            state.error = null;
            state.title = null;
        },
    },
});

export const { setError, resetErrorManager } = errorManagerSlice.actions;
export const selectErrorManager = (state: { errorManager: ErrorTxState }) => state.errorManager;
export const errorManagerReducer = errorManagerSlice.reducer;
