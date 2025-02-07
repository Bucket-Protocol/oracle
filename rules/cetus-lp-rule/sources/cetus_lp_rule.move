module cetus_lp_rule::cetus_lp_rule;

use sui::clock::{Clock};
use bucket_oracle::bucket_oracle::{BucketOracle};
use vaults::vaults::{Vault};
use cetus_clmm::pool::{Pool};
use liquidlogic_framework::float;

public struct Rule has drop {}

public fun update_price<A, B, LP>(
    oracle: &mut BucketOracle,
    vault: &Vault<LP>,
    pool: &Pool<A, B>,
    clock: &Clock,
) {
    let lp_oracle = oracle.borrow_single_oracle<LP>();
    let (a_amount, b_amount) = vault.get_position_amounts(pool, lp_oracle.precision());
    
    // compute A value
    let (a_price, a_precision) = oracle.borrow_single_oracle<A>().get_price(clock);
    let a_value = float::from_fraction(a_price, a_precision).mul_u64(a_amount).ceil();

    // compute B value
    let (b_price, b_precision) = oracle.borrow_single_oracle<B>().get_price(clock);
    let b_value = float::from_fraction(b_price, b_precision).mul_u64(b_amount).ceil();

    // compute total value and update price
    oracle
        .borrow_single_oracle_mut<LP>()
        .update_oracle_price_with_rule(Rule {}, clock, a_value + b_value);
}
