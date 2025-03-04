module lending_core::error {
    public fun incorrect_version(): u64 {1400}
    public fun not_available_version(): u64 {1401}
    public fun paused(): u64 {1500}
    public fun not_owner(): u64 {1501}
    public fun invalid_price(): u64 {1502}
    public fun invalid_amount(): u64 {1503}
    public fun invalid_pool(): u64 {1504}
    public fun invalid_coin_type(): u64 {1505}
    public fun insufficient_balance(): u64 {1506}
    public fun user_is_unhealthy(): u64 {1600}
    public fun user_have_no_collateral(): u64 {1601}
    public fun user_have_no_loan(): u64 {1602}
    public fun ltv_is_not_enough(): u64 {1603}
    public fun exceeded_maximum_deposit_cap(): u64 {1604}
    public fun exceeded_maximum_borrow_cap(): u64 {1605}
    public fun no_more_reserves_allowed(): u64 {1700}
    public fun duplicate_reserve(): u64 {1701}
    public fun non_single_value(): u64 {1801}
    public fun invalid_duration_time(): u64 {1802}
    public fun required_parent_account_cap(): u64 {1900}
    public fun reserve_not_found(): u64 {2000}
    public fun duplicate_config(): u64 {2001}
    public fun invalid_user(): u64 {2001}
}