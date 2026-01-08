import { createSlice } from '@reduxjs/toolkit';
import type { RootState } from './store';

interface ConfirmPlaceBidState {
    isConfirmBidPanelOpen: boolean;
    alreadyHigherBidder: boolean;
    enoughBalance: boolean;
    hasUnclaimedTokens: boolean;
}

const initialState: ConfirmPlaceBidState = {
    isConfirmBidPanelOpen: false,
    alreadyHigherBidder: false,
    enoughBalance: false,
    hasUnclaimedTokens: false,
};

export const confirmPlaceBidSlice = createSlice({
    name: 'confirmPlaceBid',
    initialState,
    reducers: {
        setIsConfirmBidPanelOpen: state => {
            state.isConfirmBidPanelOpen = true;
        },
        setAlreadyHigherBidder: state => {
            state.alreadyHigherBidder = true;
        },
        setEnoughBalance: state => {
            state.enoughBalance = true;
        },
        setHasUnclaimedTokens: state => {
            state.hasUnclaimedTokens = true;
        },
        resetConfirmPlaceBid: state => {
            state.isConfirmBidPanelOpen = false;
            state.alreadyHigherBidder = false;
            state.enoughBalance = false;
            state.hasUnclaimedTokens = false;
        },
    },
});

export const { setIsConfirmBidPanelOpen, setAlreadyHigherBidder, setEnoughBalance, setHasUnclaimedTokens, resetConfirmPlaceBid } =
    confirmPlaceBidSlice.actions;

export const selectConfirmPlaceBid = (state: RootState) => state.confirmPlaceBid;

export const confirmPlaceBidReducer = confirmPlaceBidSlice.reducer;
