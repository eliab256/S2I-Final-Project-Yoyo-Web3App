import { createSlice } from '@reduxjs/toolkit';
import type { RootState } from './store';

interface ConfirmPlaceBidState {
    isOpen: boolean;
    alreadyHigherBidder: boolean;
    enoughBalance: boolean;
    hasUnclaimedTokens: boolean;
}

const initialState: ConfirmPlaceBidState = {
    isOpen: false,
    alreadyHigherBidder: false,
    enoughBalance: false,
    hasUnclaimedTokens: false,
};

export const confirmPlaceBidSlice = createSlice({
    name: 'confirmPlaceBid',
    initialState,
    reducers: {
        setIsOpen: state => {
            state.isOpen = true;
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
            state.isOpen = false;
            state.alreadyHigherBidder = false;
            state.enoughBalance = false;
            state.hasUnclaimedTokens = false;
        },
    },
});

export const { setIsOpen, setAlreadyHigherBidder, setEnoughBalance, setHasUnclaimedTokens, resetConfirmPlaceBid } =
    confirmPlaceBidSlice.actions;

export const selectConfirmPlaceBid = (state: RootState) => state.confirmPlaceBid;

export const confirmPlaceBidReducer = confirmPlaceBidSlice.reducer;
