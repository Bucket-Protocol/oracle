module gcoin_rule::gcoin_rule;

use sui::clock::{Clock};
use bucket_oracle::bucket_oracle::{BucketOracle};
use unihouse::unihouse::{Unihouse};
use liquidlogic_framework::float;

public struct Rule has drop {}

public fun update_price<GCOIN, COIN>(
    oracle: &mut BucketOracle, // 0xf578d73f54b3068166d73c1a1edd5a105ce82f97f5a8ea1ac17d53e0132a1078
    unihouse: &Unihouse, // 0x75c63644536b1a7155d20d62d9f88bf794dc847ea296288ddaf306aa320168ab
    clock: &Clock,
) {
    // get coin price
    let (coin_price, coin_precision) = oracle.get_price<COIN>(clock);
    let coin_price = float::from_fraction(coin_price, coin_precision);

    // get exchange rate (ex: 1 gSUI = 1.7 SUI)
    let (
        pool_balance, _, gcoin_supply, _, pipe_debt, _,
    ) = unihouse.borrow_house<COIN>().house_metadata();
    let total_balance = pool_balance + pipe_debt;
    let exchange_rate  = float::from_fraction(total_balance, gcoin_supply);
    let gcoin_oracle = oracle.borrow_single_oracle_mut<GCOIN>();

    // compute gCoin price
    let gcoin_price = coin_price.mul(exchange_rate).mul_u64(gcoin_oracle.precision()).ceil();
    
    // update oracle
    gcoin_oracle.update_oracle_price_with_rule(
        Rule {}, clock, gcoin_price,
    );
}
