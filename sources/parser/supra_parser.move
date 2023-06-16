module bucket_oracle::supra_parser {
    use std::option::{Self, Option};
    use SupraOracle::SupraSValueFeed::{get_price, OracleHolder};
    use bucket_oracle::price_aggregator::{Self, PriceInfo};
    use sui::math::pow;

    public fun parse_price(
        oracle_holder: &OracleHolder,
        pair_id: u32,
        required_decimal: u8,
    ): Option<PriceInfo> {
        let (price_u128, decimal_u16, timestamp, _) = get_price(oracle_holder, pair_id);
        let decimal = (decimal_u16 as u8);

        if (decimal > required_decimal) {
            price_u128 = price_u128 / (pow(10, decimal - required_decimal) as u128);
        } else {
            price_u128 = price_u128 * (pow(10, required_decimal - decimal) as u128);
        };

        option::some(price_aggregator::new((price_u128 as u64), (timestamp as u64)))
    }
}