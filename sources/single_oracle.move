module bucket_oracle::single_oracle {

    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::clock::{Self, Clock};
    use sui::math;
    use std::option::{Self, Option};

    use switchboard_std::aggregator::Aggregator;
    use SupraOracle::SupraSValueFeed::OracleHolder;
    use bucket_oracle::switchboard_parser;
    use bucket_oracle::pyth_parser;
    use bucket_oracle::supra_parser;

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
        switchboard_config: Option<ID>,
        pyth_config: Option<ID>,
        supra_config: Option<u32>,
    }

    public(friend) fun new<T>(
        precision_decimal: u8,
        switchboard_config: Option<address>,
        pyth_config: Option<address>,
        supra_config: Option<u32>,
        ctx: &mut TxContext,
    ): SingleOracle<T> {
        let switchboard_config = switchboard_parser::parse_config(switchboard_config);
        let pyth_config = pyth_parser::parse_config(pyth_config);
        SingleOracle {
            id: object::new(ctx),
            price: 0,
            precision_decimal,
            precision: math::pow(10, precision_decimal),
            latest_update_ms: 0,
            epoch: 0,
            switchboard_config,
            pyth_config,
            supra_config,
        }
    }

    public fun get_price<T>(oracle: &SingleOracle<T>, _clock: &Clock): (u64, u64) {
        // don't check on testnet
        // assert!(clock::timestamp_ms(clock) - oracle.latest_update_ms <= TOLERANCE_MS, EPriceOutdated);
        (oracle.price, oracle.precision)
    }

    public fun get_tolerance_ms(): u64 { TOLERANCE_MS }

    // only on testnet
    public(friend) fun update_price_from_admin<T>(oracle: &mut SingleOracle<T>, clock: &Clock, price: u64) {
        oracle.price = price;
        oracle.latest_update_ms = clock::timestamp_ms(clock);
    }

    ////////////////////////////////////////////////////////////////////////
    //
    //    Swichboard
    //
    ////////////////////////////////////////////////////////////////////////

    public(friend) fun update_switchboard_config<T>(oracle: &mut SingleOracle<T>, config: Option<address>) {
        let config = switchboard_parser::parse_config(config);
        oracle.switchboard_config = config;
    }

    public fun is_valid_from_switchboard<T>(
        oracle: &SingleOracle<T>,
        clock: &Clock,
        source: &Aggregator,
    ): (Option<u64>, u64) {
        if (option::is_some(&oracle.switchboard_config))
            return (option::some(ENoSourceConfig), 0);
        if (option::borrow(&oracle.switchboard_config) == &object::id(source))
            return (option::some(EWrongSourceConfig), 0);
        let (price, latest_timestamp) = switchboard_parser::parse_price(source, oracle.precision_decimal);
        if (clock::timestamp_ms(clock) - latest_timestamp <= TOLERANCE_MS) {
            (option::none(), price)
        } else {
            (option::some(ESourceOutdated), price)
        }
    }

    public fun update_price_from_switchboard<T>(
        oracle: &mut SingleOracle<T>,
        clock: &Clock,
        source: &Aggregator,
        ctx: &TxContext,
    ) {
        let (error_code, price) = is_valid_from_switchboard(oracle, clock, source);
        assert!(option::is_none(&error_code), option::destroy_some(error_code));
        oracle.price = price;
        oracle.latest_update_ms = clock::timestamp_ms(clock);
        oracle.epoch = tx_context::epoch(ctx);
    }

    ////////////////////////////////////////////////////////////////////////
    //
    //    Pyth
    //
    ////////////////////////////////////////////////////////////////////////
    /// TODO

    ////////////////////////////////////////////////////////////////////////
    //
    //    Supra
    //
    ////////////////////////////////////////////////////////////////////////

    public(friend) fun update_supra_config<T>(oracle: &mut SingleOracle<T>, config: Option<u32>) {
        oracle.supra_config = config;
    }

    public fun is_valid_from_supra<T>(
        oracle: &SingleOracle<T>,
        clock: &Clock,
        source: &mut OracleHolder,
    ): (Option<u64>, u64) {
        if (option::is_some(&oracle.supra_config))
            return (option::some(ENoSourceConfig), 0);
        let pair_id = *option::borrow(&oracle.supra_config);
        let (price, latest_timestamp) = supra_parser::parse_price(source, pair_id, oracle.precision_decimal);
        if (clock::timestamp_ms(clock) - latest_timestamp <= TOLERANCE_MS) {
            (option::none(), price)
        } else {
            (option::some(ESourceOutdated), price)
        }
    }

    public fun update_price_from_supra<T>(
        oracle: &mut SingleOracle<T>,
        clock: &Clock,
        source: &mut OracleHolder,
        ctx: &TxContext,
    ) {
        let (error_code, price) = is_valid_from_supra(oracle, clock, source);
        assert!(option::is_none(&error_code), option::destroy_some(error_code));
        oracle.price = price;
        oracle.latest_update_ms = clock::timestamp_ms(clock);
        oracle.epoch = tx_context::epoch(ctx);
    }

    #[test_only]
    public fun update_price_for_testing<T>(oracle: &mut SingleOracle<T>, price: u64) {
        oracle.price = price;
    }
}