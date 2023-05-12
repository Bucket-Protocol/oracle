module bucket_oracle::single_oracle {

    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::clock::{Self, Clock};
    use sui::math;
    use std::option::{Self, Option};

    use switchboard_std::aggregator::Aggregator;
    use bucket_oracle::switchboard_parser;

    friend bucket_oracle::bucket_oracle;

    const TOLERANCE_MS: u64 = 5000;

    const ENoSourceConfig: u64 = 0;
    const EWrongSourceConfig: u64 = 1;
    const EPriceOutdated: u64 = 2;
    const ESourceOutdated: u64 = 3;

    struct SingleOracle<phantom T> has key, store {
        id: UID,
        price: u64,
        // settings
        precision_decimal: u8,
        precision: u64,
        // recordings
        latest_update_ms: u64,
        epoch: u64,
        // oracle configs
        switchboard_id_opt: Option<ID>,
        // pyth_id: Option<PriceIdentifier>,
        // supra_id: Option<vector<u8>>,
    }

    public(friend) fun new<T>(precision_decimal: u8, ctx: &mut TxContext): SingleOracle<T> {
        SingleOracle {
            id: object::new(ctx),
            price: 0,
            precision_decimal,
            precision: math::pow(10, precision_decimal),
            latest_update_ms: 0,
            epoch: 0,
            switchboard_id_opt: option::none(),
            // pyth_id: option::none(),
            // supra_id: option::none(),
        }
    }

    public fun get_price<T>(oracle: &SingleOracle<T>, clock: &Clock): (u64, u64) {
        assert!(clock::timestamp_ms(clock) - oracle.latest_update_ms <= TOLERANCE_MS, EPriceOutdated);
        (oracle.price, oracle.precision)
    }

    public fun get_tolerance_ms(): u64 { TOLERANCE_MS }

    public fun is_valid_from_switchboard<T>(oracle: &mut SingleOracle<T>,
        clock: &Clock,
        source: &Aggregator,
    ): bool {
        option::is_some(&oracle.switchboard_id_opt) &&
        option::borrow(&oracle.switchboard_id_opt) == &object::id(source) &&
        {
            let (_, latest_timestamp) = switchboard_parser::parse_switchboard_price(source, oracle.precision_decimal);
            clock::timestamp_ms(clock) - latest_timestamp <= TOLERANCE_MS
        }
    }

    public fun update_price_from_switchboard<T>(
        oracle: &mut SingleOracle<T>,
        clock: &Clock,
        source: &Aggregator,
        ctx: &TxContext
    ) {
        assert!(option::is_some(&oracle.switchboard_id_opt), ENoSourceConfig);
        assert!(option::borrow(&oracle.switchboard_id_opt) == &object::id(source), EWrongSourceConfig);
        let (price, latest_timestamp) = switchboard_parser::parse_switchboard_price(source, oracle.precision_decimal);
        let current_timestamp = clock::timestamp_ms(clock);
        assert!(current_timestamp - latest_timestamp <= TOLERANCE_MS, ESourceOutdated);
        oracle.price = price;
        oracle.latest_update_ms = current_timestamp;
        oracle.epoch = tx_context::epoch(ctx);
    }
}