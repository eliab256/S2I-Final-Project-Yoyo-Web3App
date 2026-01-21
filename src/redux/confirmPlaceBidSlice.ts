import { createSlice, type PayloadAction } from '@reduxjs/toolkit';
import type { RootState,  } from './store';

interface ConfirmPlaceBidState {
    isConfirmBidPanelOpen: boolean;
    alreadyHigherBidder: boolean;
    insufficientBalance: boolean;
    hasUnclaimedTokens: boolean;
}

const initialState: ConfirmPlaceBidState = {
    isConfirmBidPanelOpen: false,
    alreadyHigherBidder: false,
    insufficientBalance: false,
    hasUnclaimedTokens: false,
};

export const confirmPlaceBidSlice = createSlice({
    name: 'confirmPlaceBid',
    initialState,
    reducers: {
        setIsConfirmBidPanelOpen: (state, action: PayloadAction<boolean>) => {
            state.isConfirmBidPanelOpen = action.payload;
        },
        setAlreadyHigherBidder: (state, action: PayloadAction<boolean>) => {
            state.alreadyHigherBidder = action.payload;
        },
        setInsufficientBalance: (state, action: PayloadAction<boolean>) => {
            state.insufficientBalance = action.payload;
        },
        setHasUnclaimedTokens: (state, action: PayloadAction<boolean>) => {
            state.hasUnclaimedTokens = action.payload;
        },
        resetConfirmPlaceBid: () => initialState,
    },
});

//Actions
export const {
    setIsConfirmBidPanelOpen,
    setAlreadyHigherBidder,
    setInsufficientBalance,
    setHasUnclaimedTokens,
    resetConfirmPlaceBid,
} = confirmPlaceBidSlice.actions;

//Selectors
export const selectIsConfirmBidPanelOpen = (state: RootState) => state.confirmPlaceBid.isConfirmBidPanelOpen;
export const selectAlreadyHigherBidder = (state: RootState) => state.confirmPlaceBid.alreadyHigherBidder;
export const selectInsufficientBalance = (state: RootState) => state.confirmPlaceBid.insufficientBalance;
export const selectHasUnclaimedTokens = (state: RootState) => state.confirmPlaceBid.hasUnclaimedTokens;
export const selectConfirmPlaceBid = (state: RootState) => state.confirmPlaceBid;

//Reducer
export const confirmPlaceBidReducer = confirmPlaceBidSlice.reducer;
