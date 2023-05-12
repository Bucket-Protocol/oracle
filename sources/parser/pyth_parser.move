module bucket_oracle::pyth_parser {

    use std::vector;
    use std::option::{Self, Option};
    use pyth::price_identifier::{Self, PriceIdentifier};

    public fun parse_config(config: vector<u8>): Option<PriceIdentifier> {
        if (vector::is_empty(&config)) {
            option::none<PriceIdentifier>()
        } else {
            option::some(price_identifier::from_byte_vec(config))
        }
    }
}