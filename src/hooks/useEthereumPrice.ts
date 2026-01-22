import { useState, useEffect } from 'react';

/**
 * Custom hook to fetch and cache the current Ethereum price in USD.
 *
 * @remarks
 * This hook provides real-time Ethereum pricing data with intelligent caching to optimize
 * API usage and provide resilient fallback mechanisms. It implements:
 *
 * **Global Cache Strategy**: Uses a module-level cache object that persists across component
 * re-renders and remounts. The cache stores the price, timestamp, and any error state,
 * ensuring that multiple instances of this hook share the same data and don't trigger
 * redundant API calls.
 *
 * **10-Minute Cache Duration**: Cached prices remain valid for 10 minutes (600000ms).
 * Within this window, the hook immediately returns cached data without making API requests,
 * significantly reducing API load and preventing rate limiting issues.
 *
 * **Graceful Error Handling**: If the API call fails but a cached price exists, the hook
 * returns the cached price with an error message indicating cached data is being used.
 * This ensures the UI can still display pricing information even during API outages or
 * network issues.
 *
 * **CoinGecko API Integration**: Fetches data from the CoinGecko public API endpoint
 * for Ethereum price in USD. The endpoint is lightweight and returns only the necessary
 * pricing data.
 *
 * **Single Fetch on Mount**: The hook fetches data only once when the component mounts,
 * relying on the cache for subsequent renders or component remounts within the cache window.
 *
 * @used-in
 *  - `CurrentAuction.tsx` - To display the current auction price in ETH and USD.
 *
 * @returns Object containing the ETH price, loading state, error status, and cache indicator
 * @returns {number} price - The current Ethereum price in USD (0 if not yet loaded)
 * @returns {boolean} loading - True while fetching data from the API
 * @returns {string | null} error - Error message if fetch failed, null on success
 * @returns {boolean} isCached - True if the returned price is from cache and still valid
 */

// Global Cache
const cache = {
    price: null as number | null,
    timestamp: 0,
    error: null as string | null,
};

const CACHE_DURATION = 600000; // 10 minutes in milliseconds

const useEthereumPrice = () => {
    const [price, setPrice] = useState<number>(cache.price || 0);
    const [loading, setLoading] = useState<boolean>(true);
    const [error, setError] = useState<string | null>(cache.error);

    useEffect(() => {
        const fetchPrice = async () => {
            const now = Date.now();

            // Check if we have a valid cached price
            if (cache.price && cache.error === null && now - cache.timestamp < CACHE_DURATION) {
                setPrice(cache.price);
                setError(null);
                setLoading(false);
                return;
            }

            try {
                setLoading(true);
                const response = await fetch(
                    'https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd'
                );

                if (!response.ok) throw new Error('Failed to fetch');

                const data = await response.json();

                // Update cache
                cache.price = data.ethereum.usd;
                cache.timestamp = now;
                cache.error = null;

                // Update state
                setPrice(data.ethereum.usd);
                setError(null);
            } catch (err) {
                const errorMessage = 'Failed to fetch ETH price';

                // If we have a cached price, use it as a fallback
                if (cache.price) {
                    console.log('API error, used cached price');
                    setPrice(cache.price);
                    setError(`${errorMessage} (usando dato cached)`);
                } else {
                    cache.error = errorMessage;
                    setError(errorMessage);
                }

                console.error(err);
            } finally {
                setLoading(false);
            }
        };

        fetchPrice();
    }, []);

    return {
        price,
        loading,
        error,
        isCached: cache.price !== null && Date.now() - cache.timestamp < CACHE_DURATION,
    };
};

export default useEthereumPrice;
