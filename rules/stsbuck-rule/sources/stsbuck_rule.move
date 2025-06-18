module stsbuck_rule::stsbuck_rule;

use sui::clock::{Clock};
use saving_vault::{utils::{mul_div}, vault::{Vault}};
use st_sbuck::st_sbuck::{ST_SBUCK};
use bucket_oracle::bucket_oracle::{BucketOracle};
use bucket_protocol::buck::{BUCK};

/// Witness

public struct Rule has drop {}

/// Public Funs

public fun update_price(
    oracle: &mut BucketOracle,
    clock: &Clock,
    vault: &Vault<BUCK, ST_SBUCK>,
) {
    let stsbuck_oracle = oracle.borrow_single_oracle_mut<ST_SBUCK>();
    let precision = stsbuck_oracle.precision();
    let price = mul_div(
        precision,
        vault.total_available_balance(clock),
        vault.total_yt_supply(),
    );
    stsbuck_oracle.update_oracle_price_with_rule(Rule {}, clock, price);
}
