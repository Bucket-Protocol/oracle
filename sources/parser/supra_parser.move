module bucket_oracle::supra_parser {
    
    use sui::math::pow;
    use supra::SupraSValueFeed::{Self, OracleHolder};

    public fun parse_price(oracle_holder: &mut OracleHolder, pair_id: u32, required_decimal: u8): (u64, u64) {
        let (price_u128, decimal_u16, timestamp_u128, _) = SupraSValueFeed::get_price(oracle_holder, pair_id);

        let decimal = (decimal_u16 as u8);
        if (decimal > required_decimal) {
            price_u128 = price_u128 / (pow(10, decimal - required_decimal) as u128);
        } else {
            price_u128 = price_u128 * (pow(10, required_decimal - decimal) as u128);
        };

        ((price_u128 as u64), (timestamp_u128 as u64))
    }
}