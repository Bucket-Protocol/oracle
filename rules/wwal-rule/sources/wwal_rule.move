module wwal_rule::wwal_rule;

use bucket_oracle::bucket_oracle::{BucketOracle};
use sui::clock::{Clock}; 
use walrus::system::{ System as WalrusSystem};
use wal::wal::{WAL};
use blizzard::blizzard_protocol::{BlizzardStaking};
use wwal::wwal::{WWAL};


public struct Rule has drop{}

const ONE_WAL: u64 = 1_000_000_000;
const PRECISION: u64 = 1_000_000;


const ELstAmountIsNone: u64 = 0;
fun err_lst_amount_is_none() { abort ELstAmountIsNone }

public fun update_price(
    oracle: &mut BucketOracle,
    staking: &mut BlizzardStaking<WWAL>,
    system: &WalrusSystem,
    clock: &Clock,
) { 
    let (wal_price, wal_precision) = oracle.get_price<WAL>(clock);
    let current_epoch = system.epoch();
    let wwal_amt_for_one_wal = staking.to_lst_at_epoch(current_epoch, ONE_WAL, false);

    if (wwal_amt_for_one_wal.is_none()) {
        err_lst_amount_is_none();
    };
    
    let exchange_rate = mul_and_div( ONE_WAL, PRECISION, wwal_amt_for_one_wal.destroy_some());
    let wwal_price = mul_and_div(wal_price, exchange_rate, PRECISION);
    let wwal_oracle = oracle.borrow_single_oracle_mut<WWAL>();
    let wwal_precision = wwal_oracle.precision();
    let wwal_price = mul_and_div(wwal_price, wwal_precision, wal_precision);
    wwal_oracle.update_oracle_price_with_rule(Rule{}, clock, wwal_price);
}


fun mul_and_div(x: u64, n: u64, m: u64): u64 {
    (((x as u128) * (n as u128) / (m as u128)) as u64)
}