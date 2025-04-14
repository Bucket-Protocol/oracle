module hawal_rule::hawal_rule;

use sui::clock::{Clock};
use bucket_oracle::bucket_oracle::{BucketOracle};
use haedal::{
    walstaking::{ Staking as WalStaking},
    hawal::{HAWAL},
};
use wal::wal::{WAL};


public struct Rule has drop {}

public fun update_price(
    oracle: &mut BucketOracle,
    staking: &WalStaking,
    clock: &Clock,
){
    let (wal_price, wal_precision) = oracle.get_price<WAL>(clock);
    let exchange_rate = staking.get_exchange_rate();
    let hawal_price = mul_and_div(wal_price, exchange_rate, rate_precision());
    let hawal_oracle = oracle.borrow_single_oracle_mut<HAWAL>();
    let hawal_precision = hawal_oracle.precision();
    let hawal_price = mul_and_div(hawal_precision, hawal_price, wal_precision);
    hawal_oracle.update_oracle_price_with_rule(Rule{}, clock, hawal_price);
}

public fun rate_precision(): u64 { 1_000_000 }

fun mul_and_div(x: u64, n: u64, m: u64): u64 {
    (((x as u128) * (n as u128) / (m as u128)) as u64)
}
