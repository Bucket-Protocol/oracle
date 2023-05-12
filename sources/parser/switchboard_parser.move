module bucket_oracle::switchboard_parser {

    use std::option::{Self, Option};
    use sui::object::{Self, ID};
    use sui::math::pow;
    use switchboard_std::aggregator::{Self, Aggregator};
    use switchboard_std::math;

    const EInvalidPrice: u64 = 0;

    public fun parse_price(feed: &Aggregator, required_decimal: u8): (u64, u64) {
        let (price_u128, decimal, latest_timestamp) = extract_aggregator_info(feed);
        assert!(price_u128 > 0, EInvalidPrice);

        if (decimal > required_decimal) {
            price_u128 = price_u128 / (pow(10, decimal - required_decimal) as u128);
        } else {
            price_u128 = price_u128 * (pow(10, required_decimal - decimal) as u128);
        };

        ((price_u128 as u64), latest_timestamp)
    }

    public fun extract_aggregator_info(feed: &Aggregator): (u128, u8, u64) {
        let (
            latest_result,
            latest_timestamp
        ) = aggregator::latest_value(feed);

        // get latest value
        let (value, scaling_factor, _) = math::unpack(latest_result);
        (value, scaling_factor, latest_timestamp)
    }

    public fun parse_config(config: Option<address>): Option<ID> {
        if (option::is_none(&config)) {
            option::none<ID>()
        } else {
            option::some(object::id_from_address(option::destroy_some(config)))
        }
    }
}