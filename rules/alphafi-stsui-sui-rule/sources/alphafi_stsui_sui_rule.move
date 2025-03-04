module alphafi_stsui_sui_rule::alphafi_stsui_sui_rule;

use sui::clock::{Clock};
use bucket_oracle::bucket_oracle::{BucketOracle};
use alphafi_fungible::alphafi_bluefin_stsui_sui_ft_pool::{Pool as AlphaFiPool};
use alphafi_fungible::alphafi_bluefin_stsui_sui_ft_investor::{Investor};
use bluefin_spot::pool::{Pool as BluefinPool};
use liquidlogic_framework::float;

public struct Rule has drop {}

public fun update_price<A, B, LP>(
    oracle: &mut BucketOracle,
    // 0x0b45d1e5889b524dc1a472f59651cdedb8e0a2678e745f27975a9b57c127acdd
    alphafi_pool: &AlphaFiPool<A, B, LP>,
    // 0xaec347c096dd7e816febd8397be4cca3aabc094a9a2a1f23d7e895564f859dc2
    alphafi_investor: &mut Investor<A, B>,
    // 0xde705d4f3ded922b729d9b923be08e1391dd4caeff8496326123934d0fb1c312
    bluefin_pool: &BluefinPool<A, B>,
    clock: &Clock,
) {
    let lp_oracle = oracle.borrow_single_oracle<LP>();
    let (a_amount, b_amount) = alphafi_pool.get_fungible_token_amounts(
        alphafi_investor, bluefin_pool, lp_oracle.precision(),
    );
    
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

