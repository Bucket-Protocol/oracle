module bucket_oracle::bucket_oracle {
    
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_object_field as dof;
    use sui::sui::SUI;
    use sui::clock::Clock;
    use std::option::{Self, Option};

    use bucket_oracle::single_oracle::{Self, SingleOracle};

    struct AdminCap has key { id: UID }

    struct BucketOracle has key { id: UID }

    struct PriceType<phantom T> has copy, drop, store {}

    fun init(ctx: &mut TxContext) {
        let (oracle, admin_cap) = new_oracle(ctx);
        create_single_oracle<SUI>(
            &admin_cap,
            &mut oracle,
            6,
            option::none(),
            option::none(),
            option::none(),
            ctx
        );
        transfer::transfer(admin_cap, tx_context::sender(ctx));
        transfer::share_object(oracle);
    }

    fun new_oracle(ctx: &mut TxContext): (BucketOracle, AdminCap) {
        (BucketOracle { id: object::new(ctx) }, AdminCap { id: object::new(ctx) })
    }

    public entry fun create_single_oracle<T>(
        _: &AdminCap,
        bucket_oracle: &mut BucketOracle,
        precision_decimal: u8,
        switchboard_config: Option<address>,
        pyth_config: Option<address>,
        supra_config: Option<u32>,
        ctx: &mut TxContext,
    ) {
        dof::add<PriceType<T>, SingleOracle<T>>(
            &mut bucket_oracle.id,
            PriceType<T> {}, 
            single_oracle::new(
                precision_decimal,
                switchboard_config,
                pyth_config,
                supra_config,
                ctx
            ),
        );
    }

    public entry fun update_switchboard_config<T>(
        _: &AdminCap,
        bucket_oracle: &mut BucketOracle,
        switchboard_config: Option<address>,
    ) {
        let oracle = borrow_single_oracle_mut<T>(bucket_oracle);
        single_oracle::update_switchboard_config<T>(oracle, switchboard_config);
    }

    public entry fun update_supra_config<T>(
        _: &AdminCap,
        bucket_oracle: &mut BucketOracle,
        supra_config: Option<u32>,
    ) {
        let oracle = borrow_single_oracle_mut<T>(bucket_oracle);
        single_oracle::update_supra_config<T>(oracle, supra_config);
    }

    // only on testnet
    public entry fun update_price<T>(
        _: &AdminCap,
        bucket_oracle: &mut BucketOracle,
        clock: &Clock,
        price: u64,
    ) {
        let oracle = borrow_single_oracle_mut<T>(bucket_oracle);
        single_oracle::update_price_from_admin<T>(oracle, clock, price);
    }

    public fun get_price<T>(bucket_oracle: &BucketOracle, clock: &Clock): (u64, u64) {
        single_oracle::get_price<T>(borrow_single_oracle(bucket_oracle), clock)
    }

    public fun borrow_single_oracle<T>(bucket_oracle: &BucketOracle): &SingleOracle<T> {
        dof::borrow<PriceType<T>, SingleOracle<T>>(&bucket_oracle.id, PriceType<T> {})
    }

    public fun borrow_single_oracle_mut<T>(bucket_oracle: &mut BucketOracle): &mut SingleOracle<T> {
        dof::borrow_mut<PriceType<T>, SingleOracle<T>>(&mut bucket_oracle.id, PriceType<T> {})
    }

    #[test_only]
    public fun new_for_testing<T>(precision_decimal: u8, ctx: &mut TxContext): (BucketOracle, AdminCap) {
        let (oracle, admin_cap) = new_oracle(ctx);
        create_single_oracle<SUI>(
            &admin_cap,
            &mut oracle,
            6,
            option::none(),
            option::none(),
            option::none(),
            ctx
        );
        (oracle, admin_cap)
    }

    #[test_only]
    public fun update_price_for_testing<T>(bucket_oracle: &mut BucketOracle, price: u64) {
        let oracle = borrow_single_oracle_mut<T>(bucket_oracle);
        single_oracle::update_price_for_testing(oracle, price);
    }
}