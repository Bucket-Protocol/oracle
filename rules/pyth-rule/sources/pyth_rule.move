module pyth_rule::pyth_rule;

use std::type_name::{Self, TypeName};
use sui::clock::Clock;
use sui::vec_map::{Self, VecMap};
use pyth::pyth;
use pyth::state::{Self, State as PythState};
use pyth::price_info::PriceInfoObject;
use pyth::price;
use pyth::i64;
use bucket_oracle::bucket_oracle::{BucketOracle, AdminCap};

/// Errors

const EUnsupportedCoinType: u64 = 0;
fun err_unsupported_coin_type() { abort EUnsupportedCoinType }

const EInvalidPriceInfoObject: u64 = 1;
fun err_invalid_price_info_object() { abort EInvalidPriceInfoObject }

/// Witness

public struct Rule has drop {}

/// Object

public struct PythRuleConfig has key {
    id: UID,
    identifier_map: VecMap<TypeName, vector<u8>>,
}

/// Init fun

fun init(ctx: &mut TxContext) {
    transfer::share_object(PythRuleConfig {
        id: object::new(ctx),
        identifier_map: vec_map::empty(),
    });
}

/// Public Funs

public fun update_price<T>(
    config: &PythRuleConfig,
    oracle: &mut BucketOracle,
    clock: &Clock,
    pyth_state: &PythState,
    price_info_object: &PriceInfoObject,
) {
    let coin_type = type_name::get<T>();
    if (!config.identifier_map.contains(&coin_type)) {
        err_unsupported_coin_type();
    };
    let coin_identifier = *config.identifier_map.get(&coin_type);
    let price_info_object_id = object::id(price_info_object);
    let expected_object_id = state::get_price_info_object_id(pyth_state, coin_identifier);
    if (price_info_object_id != expected_object_id) {
        err_invalid_price_info_object();
    };
    let (pyth_price, pyth_decimal) = get_price(pyth_state, price_info_object, clock);
    let pyth_preicision = 10u64.pow(pyth_decimal as u8);
    let single_oracle = oracle.borrow_single_oracle_mut<T>();
    let single_precision = single_oracle.precision();
    let price_result = mul_and_div(single_precision, pyth_price, pyth_preicision);
    single_oracle.update_oracle_price_with_rule(Rule{}, clock, price_result);
}

/// Admin Funs

public fun set_identifier<T>(
    config: &mut PythRuleConfig,
    _cap: &AdminCap,
    identifier: vector<u8>,
) {
    let coin_type = type_name::get<T>();
    if (config.identifier_map.contains(&coin_type)) {
        *config.identifier_map.get_mut(&coin_type) = identifier;
    } else {
        config.identifier_map.insert(coin_type, identifier);
    };
}

public fun remove_identifier<T>(
    config: &mut PythRuleConfig,
    _cap: &AdminCap,
) {
    let coin_type = type_name::get<T>();
    if (config.identifier_map.contains(&coin_type)) {
        config.identifier_map.remove(&coin_type);
    };
}

/// Internal Funs

fun get_price(
    pyth_state: &PythState,
    price_info_object: &PriceInfoObject,
    clock: &Clock
): (u64, u64) {

    let price_result = pyth::get_price(pyth_state, price_info_object, clock);

    let price = price::get_price(&price_result);
    let expo = price::get_expo(&price_result);

    let price = i64::get_magnitude_if_positive(&price);
    let decimal = i64::get_magnitude_if_negative(&expo);

    (price, decimal)
}

fun mul_and_div(x: u64, n: u64, m: u64): u64 {
    (((x as u128) * (n as u128) / (m as u128)) as u64)
}
