module stsui_rule::stsui_rule;

use sui::sui::SUI;
use sui::clock::Clock;
use bucket_oracle::bucket_oracle::{Self as bo, BucketOracle};
use liquid_staking::liquid_staking::{LiquidStakingInfo};

public struct Rule has drop {}

public fun update_price<LST: drop>(
    oracle: &mut BucketOracle,
    info: &LiquidStakingInfo<LST>,
    clock: &Clock,
) {
    let (sui_price, sui_precision) = bo::get_price<SUI>(oracle, clock);
    let lst_unit = info.sui_to_lst_mint_price(sui_precision);
    let lst_oracle = oracle.borrow_single_oracle_mut<LST>();
    let lst_price = (
        lst_oracle.precision() as u128) *
        (sui_price as u128) / 
        (lst_unit as u128);
    lst_oracle.update_oracle_price_with_rule(
        Rule {}, clock, (lst_price as u64),
    );
}
