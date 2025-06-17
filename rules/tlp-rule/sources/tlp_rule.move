module tlp_rule::tlp_rule;

use std::type_name::{Self, TypeName};
use sui::vec_map::{Self, VecMap};
use sui::clock::{Clock};
use bucket_oracle::bucket_oracle::{BucketOracle, AdminCap};
use typus_perp::lp_pool::{Self, Registry};
use typus_perp::admin::{Version};

/// Errors
const EUnsupportedTlpType: u64 = 0;
fun err_unsupported_tlp_type() { abort EUnsupportedTlpType }

/// Witness

public struct Rule has drop {}

/// Object

public struct IndexMap has key {
    id: UID,
    inner: VecMap<TypeName, u64>,
}

/// Init Fun

fun init(ctx: &mut TxContext) {
    let map = IndexMap {
        id: object::new(ctx),
        inner: vec_map::empty(),
    };
    transfer::share_object(map);
}

/// Public Fun

public fun update_price<TLP>(
    map: &IndexMap,
    oracle: &mut BucketOracle,
    clock: &Clock,
    version: &Version,
    registry: &Registry,
) {
    let tlp_type = type_name::get<TLP>();
    if (!map.inner.contains(&tlp_type)) {
        err_unsupported_tlp_type();
    };
    let index = *map.inner.get(&tlp_type);
    let (total_share_supply, tvl_usd, _, _, _) = lp_pool::get_pool_liquidity(version, registry, index);
    let tlp_oracle = oracle.borrow_single_oracle_mut<TLP>();
    let tlp_price = mul_and_div(tlp_oracle.precision(), tvl_usd, total_share_supply);
    tlp_oracle.update_oracle_price_with_rule(Rule {}, clock, tlp_price);
}

/// Admin Funs

public fun set_index<TLP>(
    map: &mut IndexMap,
    _cap: &AdminCap,
    index: u64,
) {
    let tlp_type = type_name::get<TLP>();
    if (map.inner.contains(&tlp_type)) {
        *map.inner.get_mut(&tlp_type) = index;
    } else {
        map.inner.insert(tlp_type, index);
    }
}

public fun remove_index<TLP>(
    map: &mut IndexMap,
    _cap: &AdminCap,
) {
    let tlp_type = type_name::get<TLP>();
    map.inner.remove(&tlp_type);
}

/// Internal Fun

fun mul_and_div(x: u64, n: u64, m: u64): u64 {
    (((x as u128) * (n as u128) / (m as u128)) as u64)
}
