module supra::price_feed {

    struct OracleHolder has key, store {
        id: sui::object::UID,
    }

    struct Price has drop {
        pair: u32,
        value: u128,
        decimal: u16,
        timestamp: u128,
        round: u64
    }
    
    native public fun get_price(oracle_holder: &mut OracleHolder, pair: u32): (u128, u16, u128, u64);
    
    native public fun get_prices(oracle_holder: &mut OracleHolder, pairs: vector<u32>): vector<Price>;
    
    native public fun extract_price(price: &Price): (u32, u128, u16, u128, u64);
}