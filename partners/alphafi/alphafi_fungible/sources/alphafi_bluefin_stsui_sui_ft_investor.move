#[allow(lint(self_transfer))]
module alphafi_fungible::alphafi_bluefin_stsui_sui_ft_investor {
    use sui::clock::Clock;
    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::event;
    use sui::bag::{Self, Bag};
    use sui::sui::SUI;
    use std::type_name;
    // The `Investor` struct is used to keep track of investment details for Cetus V3 pools.
    // It is a generic struct that can handle different types of assets.

    // Struct definition with generic parameters `T` and `S`.
    public struct Investor<phantom T, phantom S> has key, store {
        /// Unique identifier for the investor.
        id: UID,
        
        /// The lower bound of the tick range for the investment.
        lower_tick: u32,
        
        /// The upper bound of the tick range for the investment.
        upper_tick: u32,

        /// The balance of asset type `T` that is freely available.
        free_balance_a: Balance<T>,
        
        /// The balance of asset type `S` that is freely available.
        free_balance_b: Balance<S>,

        /// to store the balance in case of emergency
        emergency_balance_a: Balance<T>,

        /// to store the balance in case of emergency
        emergency_balance_b: Balance<S>,

        /// added when rewards to be swapped are too small.
        /// always less than 1e5. 
        free_rewards: Bag,

        // wont swap unless swap amount is greater than this value.
        minimum_swap_amount: u64,

        /// The performance fee rate applied to the investment, represented as a percentage (e.g., 1% = 100).
        performance_fee: u64,
        
        /// The maximum cap for the performance fee, beyond which no additional fee is charged.
        performance_fee_max_cap: u64,

        /// emergency situation bool
        is_emergency: bool
        
    }


    

}
