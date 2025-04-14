module navi_rule::navi_rule;

use std::type_name::{get, TypeName};
use sui::vec_map::{Self, VecMap};
use sui::clock::{Clock};
use oracle::oracle::{Self, PriceOracle};
use bucket_oracle::bucket_oracle::{BucketOracle};

const ECoinTypeNotSupported: u64 = 0;
fun err_coin_type_not_supported() { abort ECoinTypeNotSupported }

const ENotValidPrice: u64 = 1;
fun err_not_valid_price() { abort ENotValidPrice }

public struct Rule has drop {}

public struct AdminCap has key, store {
    id: UID,
}

public struct Config has key {
    id: UID,
    index_map: VecMap<TypeName, u8>,
}

fun init(ctx: &mut TxContext) {
    let config = Config {
        id: object::new(ctx),
        index_map: vec_map::empty(),
    };
    transfer::share_object(config);

    let cap = AdminCap { id: object::new(ctx) };
    transfer::transfer(cap, ctx.sender());
}

/// Public Funs

public fun update_price<T>(
    config: &Config,
    oracle: &mut PriceOracle,
    bucket_oracle: &mut BucketOracle,
    clock: &Clock,
) {
    let coin_name = get<T>();
    if (!config.index_map.contains(&coin_name)) err_coin_type_not_supported();
    let asset_index = *config.index_map.get(&coin_name);
    let (is_valid, price_n, decimals) = oracle::get_token_price(clock, oracle, asset_index);
    let price_m = base_u256().pow(decimals);
    let precision = bucket_oracle.borrow_single_oracle<T>().precision();
    if (!is_valid) err_not_valid_price();
    let price = (price_n * (precision as u256) / price_m) as u64;
    bucket_oracle
        .borrow_single_oracle_mut<T>()
        .update_oracle_price_with_rule(Rule {}, clock, price);
}

/// Admin Funs

public fun add_asset_index<T>(
    _: &AdminCap,
    config: &mut Config,
    index: u8,
) {
    config.index_map.insert(get<T>(), index);
}

public fun remove_asset_index<T>(
    _: &AdminCap,
    config: &mut Config,
) {
    config.index_map.remove(&get<T>());
}

/// Internal Funs

fun base_u256(): u256 { 10_u256 }
