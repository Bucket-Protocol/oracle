/// Module: scoin_rule
module scallop_rule::scoin_rule;

// Dependencies

use std::type_name::{Self, TypeName};
use sui::clock::{Clock};
use sui::vec_set::{Self, VecSet};
use bucket_oracle::bucket_oracle::{BucketOracle};
use scallop_rule::utils;

// Errors

const EInvalidScoinTypeInputs: u64 = 0;
fun err_invalid_scoin_type_inputs() { abort EInvalidScoinTypeInputs }

// Witness

public struct Rule has drop {}

// Objects

public struct SCoinPair has copy, drop, store {
    scoin_type: TypeName,
    coin_type: TypeName,
}

public struct Config has key {
    id: UID,
    scoin_pairs: VecSet<SCoinPair>,
}

public struct AdminCap has key, store {
    id: UID,
}

// Constructor

fun init(ctx: &mut TxContext) {
    transfer::share_object(
        Config {
            id: object::new(ctx),
            scoin_pairs: vec_set::empty(),
        }
    );
    transfer::transfer(
        AdminCap { id: object::new(ctx) },
        ctx.sender(),
    );
}

// Admin Funs

public fun add_scoin_pair<SCOIN, COIN>(
    config: &mut Config,
    _: &AdminCap,
) {
    config.scoin_pairs.insert(
        new_scoin_pair<SCOIN, COIN>(),
    );
}

public fun remove_scoin_pair<SCOIN, COIN>(
    config: &mut Config,
    _: &AdminCap,
) {
    config.scoin_pairs.remove(
        &new_scoin_pair<SCOIN, COIN>(),
    );
}

// Public Funs

public fun update_price<SCOIN, COIN>(
    config: &Config,
    oracle: &mut BucketOracle,
    version: &protocol::version::Version,
    market: &mut protocol::market::Market, 
    clock: &Clock,
) {
    if (!config.exists_pair<SCOIN, COIN>()) {
        err_invalid_scoin_type_inputs();
    };
    let coin_type = type_name::get<COIN>();
    let (coin_price, coin_precision) = oracle.get_price<COIN>(clock);
    let scoin_unit = utils::calc_coin_to_scoin(
        version, market, coin_type, clock, coin_precision,
    );
    let scoin_oracle = oracle.borrow_single_oracle_mut<SCOIN>();
    let scoin_price = (
        scoin_oracle.precision() as u128) *
        (coin_price as u128) / 
        (scoin_unit as u128);
    scoin_oracle.update_oracle_price_with_rule(
        Rule {}, clock, (scoin_price as u64),
    );
}

// Getter Funs

public fun exists_pair<SCOIN, COIN>(config: &Config): bool {
    config.scoin_pairs.contains(
        &new_scoin_pair<SCOIN, COIN>(),
    )
}

// Internal Funs

fun new_scoin_pair<SCOIN, COIN>(): SCoinPair {
    SCoinPair {
        scoin_type: type_name::get<SCOIN>(),
        coin_type: type_name::get<COIN>(),
    }
}