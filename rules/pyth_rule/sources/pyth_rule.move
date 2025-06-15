module pyth_rule::pyth_rule {

    use std::type_name::{Self, TypeName};
    use sui::clock::Clock;
    use sui::math;
    use sui::vec_set::{Self, VecSet};
    use pyth::pyth;
    use pyth::state::{Self, State as PythState};
    use pyth::price_info::PriceInfoObject;
    use pyth::price;
    use pyth::i64;
    use blast_off::listing::ListingCap;
    use blast_off::oracle::{Self, Oracle};
    use blast_off::config;

    //***********************
    //  Constants
    //***********************

    const SUI_IDENTIFIER_BYTES: vector<u8> = x"23d7315113f5b1d3ba7a83604c44b94d79f4fd69af77f804fc7f920a6dc65744";

    //***********************
    //  Errors
    //***********************

    const EInvalidPriceInfoObject: u64 = 0;
    fun err_invalid_price_info_object() { abort EInvalidPriceInfoObject }

    const EInvalidStableType: u64 = 1;
    fun err_invalid_stable_type() { abort EInvalidStableType }


    //***********************
    //  Objects
    //***********************

    public struct Rule has drop {}

    public struct StableTypes has key {
        id: UID,
        types: VecSet<TypeName>,
    }

    //***********************
    //  Constructor Functions
    //***********************

    fun init(ctx: &mut TxContext) {
        transfer::share_object(StableTypes {
            id: object::new(ctx),
            types: vec_set::empty(),
        });
    }

    //***********************
    //  Public Functions
    //***********************

    public fun update_blast_off_oracle<T>(
        oracle: &mut Oracle,
        clock: &Clock,
        pyth_state: &PythState,
        price_info_object: &PriceInfoObject,
        stable: &StableTypes,
    ) {
        if (!is_stable_type<T>(stable)) err_invalid_stable_type();
        let price_info_object_id = object::id(price_info_object);
        let expected_object_id = state::get_price_info_object_id(pyth_state, SUI_IDENTIFIER_BYTES);
        if (price_info_object_id != expected_object_id) err_invalid_price_info_object();
        let (price, decimals) = get_price(pyth_state, price_info_object, clock);
        let pyth_preicision = (math::pow(10, (decimals as u8)) as u128);
        let buck_price_against_sui = config::precision() * pyth_preicision / (price as u128) * 10 / 9;
        oracle::update_price<T, Rule>(Rule {}, oracle, clock, buck_price_against_sui);
    }

    public fun is_stable_type<T>(stable: &StableTypes): bool {
        vec_set::contains(&stable.types, &type_name::get<T>())
    }

    public fun add_stable_type<T>(
        _: &ListingCap,
        stable: &mut StableTypes,
    ) {
        vec_set::insert(&mut stable.types, type_name::get<T>());
    }

    public fun remove_stable_type<T>(
        _: &ListingCap,
        stable: &mut StableTypes,
    ) {
        vec_set::remove(&mut stable.types, &type_name::get<T>());
    }

    //***********************
    //  Internal Functions
    //***********************

    fun get_price(
        pyth_state: &PythState,
        price_info_object: &PriceInfoObject,
        clock: &Clock
    ): (u64, u64) {

        let price_result = pyth::get_price(pyth_state, price_info_object, clock);

        let price = price::get_price(&price_result);
        let expo = price::get_expo(&price_result);

        let price = i64::get_magnitude_if_positive(&price);
        let decimal = i64::get_magnitude_if_negative(&expo);

        (price, decimal)
    }
}
