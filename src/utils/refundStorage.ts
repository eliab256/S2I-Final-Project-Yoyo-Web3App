import type { Address } from 'viem';

const STORAGE_KEY = 'yoyo_viewed_refunds';

interface ViewedRefunds {
    [walletAddress: string]: string[]; // array of transaction hashes seen for this address
}

export function getViewedRefunds(address: Address): string[] {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (!stored) return [];
    
    const parsed: ViewedRefunds = JSON.parse(stored);
    return parsed[address.toLowerCase()] || [];
}

export function markRefundAsViewed(address: Address, transactionHash: string): void {
    const stored = localStorage.getItem(STORAGE_KEY);
    const parsed: ViewedRefunds = stored ? JSON.parse(stored) : {};
    
    const addressKey = address.toLowerCase();
    if (!parsed[addressKey]) {
        parsed[addressKey] = [];
    }
    
    if (!parsed[addressKey].includes(transactionHash)) {
        parsed[addressKey].push(transactionHash);
    }
    
    localStorage.setItem(STORAGE_KEY, JSON.stringify(parsed));
}

export function clearViewedRefunds(address: Address): void {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (!stored) return;
    
    const parsed: ViewedRefunds = JSON.parse(stored);
    delete parsed[address.toLowerCase()];
    localStorage.setItem(STORAGE_KEY, JSON.stringify(parsed));
}