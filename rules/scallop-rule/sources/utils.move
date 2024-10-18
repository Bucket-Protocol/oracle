module scallop_rule::utils;

public fun calc_coin_to_scoin(
    version: &protocol::version::Version,
    market: &mut protocol::market::Market, 
    coin_type: std::type_name::TypeName, 
    clock: &sui::clock::Clock,
    coin_amount: u64,
): u64 {
    let (
        cash, debt, revenue, market_coin_supply,
    ) = get_reserve_stats(version, market, coin_type, clock);

    let scoin_amount = if (market_coin_supply > 0) {
        math::u64::mul_div(
            coin_amount,
            market_coin_supply,
            cash + debt - revenue
        )
    } else {
        coin_amount
    };

    // if the coin is too less, just throw error
    assert!(scoin_amount > 0, 1);
    
    scoin_amount
}

public fun calc_scoin_to_coin(
    version: &protocol::version::Version,
    market: &mut protocol::market::Market, 
    coin_type: std::type_name::TypeName, 
    clock: &sui::clock::Clock,
    scoin_amount: u64,
): u64 {
    let (
        cash, debt, revenue, market_coin_supply,
    ) = get_reserve_stats(version, market, coin_type, clock);
    
    let coin_amount = math::u64::mul_div(
        scoin_amount,
        cash + debt - revenue,
        market_coin_supply
    );

    coin_amount
}

public fun get_reserve_stats(
    version: &protocol::version::Version,
    market: &mut protocol::market::Market,
    coin_type: std::type_name::TypeName,
    clock: &sui::clock::Clock,
): (u64, u64, u64, u64) {
    // update to the latest reserve stats
    // NOTE: this function needs to be called to get an accurate data
    protocol::accrue_interest::accrue_interest_for_market(
        version, market, clock
    );

    let vault = protocol::market::vault(market);
    let balance_sheets = protocol::reserve::balance_sheets(vault);

    let balance_sheet = x::wit_table::borrow(balance_sheets, coin_type);
    let (cash, debt, revenue, market_coin_supply) = protocol::reserve::balance_sheet(balance_sheet);
    (cash, debt, revenue, market_coin_supply)
}