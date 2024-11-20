module springsui_rule::ssui_rule;

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
    let lst_unit = sui_amount_to_lst_amount(info, sui_precision);
    let lst_oracle = oracle.borrow_single_oracle_mut<LST>();
    let lst_price = (
        lst_oracle.precision() as u128) *
        (sui_price as u128) / 
        (lst_unit as u128);
    lst_oracle.update_oracle_price_with_rule(
        Rule {}, clock, (lst_price as u64),
    );
}

public fun sui_amount_to_lst_amount<P>(
    self: &LiquidStakingInfo<P>,
    sui_amount: u64,
): u64 {
    let total_sui_supply = self.total_sui_supply();
    let total_lst_supply = self.total_lst_supply();

    if (total_sui_supply == 0 || total_lst_supply == 0) {
        return sui_amount
    };

    let lst_amount = (total_lst_supply as u128)
        * (sui_amount as u128)
        / (total_sui_supply as u128);

    lst_amount as u64
}