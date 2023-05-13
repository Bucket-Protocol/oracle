module bucket_oracle::pyth_parser {

    use std::option::{Self, Option};
    use sui::object::{Self, ID};

    public fun parse_config(config: Option<address>): Option<ID> {
        if (option::is_none(&config)) {
            option::none<ID>()
        } else {
            option::some(object::id_from_address(option::destroy_some(config)))
        }
    }
}