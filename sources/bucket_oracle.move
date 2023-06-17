module bucket_oracle::bucket_oracle {
    
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_object_field as dof;
    use sui::sui::SUI;
    use sui::clock::Clock;
    use std::option::{Self, Option};
    use std::type_name;

    use bucket_oracle::single_oracle::{Self, SingleOracle};
    use switchboard_std::aggregator::Aggregator;
    use SupraOracle::SupraSValueFeed::OracleHolder;

    // Testnet Coin Types
    use testnet_coins::wbtc::WBTC;
    use testnet_coins::weth::WETH;
    use testnet_coins::usdt::USDT;
    use testnet_coins::usdc::USDC;

    // SUI
    const SUI_SWITCHBOARD_CONFIG: address = @0x84d2b7e435d6e6a5b137bf6f78f34b2c5515ae61cd8591d5ff6cd121a21aa6b7;
    const SUI_PYTH_CONFIG: address = @0xe38dbe2ff3322f1500fff45d0046101f371eebce47c067c5e9233248c4878c28;
    const SUI_SUPRA_CONFIG: u32 = 90;

    // BTC
    const BTC_SWITCHBOARD_CONFIG: address = @0x7c30e48db7dfd6a2301795be6cb99d00c87782e2547cf0c63869de244cfc7e47;
    const BTC_PYTH_CONFIG: address = @0x878b118488aeb5763b5f191675c3739a844ce132cb98150a465d9407d7971e7c;
    const BTC_SUPRA_CONFIG: u32 = 18;

    // ETH
    const ETH_SWITCHBOARD_CONFIG: address = @0x68ed81c5dd07d12c629e5cdad291ca004a5cd3708d5659cb0b6bfe983e14778c;
    const ETH_PYTH_CONFIG: address = @0x8deeebad0a8fb86d97e6ad396cc84639da5a52ae4bbc91c78eb7abbf3e641ed6;
    const ETH_SUPRA_CONFIG: u32 = 19;
    
    // USDT
    const USDT_SWITCHBOARD_CONFIG: address = @0xe8a09db813c07b0a30c9026b3ff7d5617d2505a097f1a90a06a941d34bee9585;
    const USDT_PYTH_CONFIG: address = @0x83f74b8a33b540cbf1edd24e219eac1215d1668a711ca2be3aa5d703763f91db;
    const USDT_SUPRA_CONFIG: u32 = 48;

    // USDC
    const USDC_SWITCHBOARD_CONFIG: address = @0xde58993e6aabe1248a9956557ba744cb930b61437f94556d0380b87913d5ef47;
    const USDC_PYTH_CONFIG: address = @0xa3d3e81bd7e890ac189b3f581b511f89333b94f445c914c983057e1ac09ff296;
    const USDC_SUPRA_CONFIG: u32 = 89;

    struct AdminCap has key { id: UID }

    struct BucketOracle has key { id: UID }

    struct PriceType<phantom T> has copy, drop, store {}

    fun init(ctx: &mut TxContext) {
        let (oracle, admin_cap) = new_oracle(ctx);
        create_single_oracle<SUI>(
            &admin_cap,
            &mut oracle,
            6,
            option::some(SUI_SWITCHBOARD_CONFIG),
            option::some(SUI_PYTH_CONFIG),
            option::some(SUI_SUPRA_CONFIG),
            ctx,
        );
        create_single_oracle<WBTC>(
            &admin_cap,
            &mut oracle,
            2,
            option::some(BTC_SWITCHBOARD_CONFIG),
            option::some(BTC_PYTH_CONFIG),
            option::some(BTC_SUPRA_CONFIG),
            ctx,
        );
        create_single_oracle<WETH>(
            &admin_cap,
            &mut oracle,
            3,
            option::some(ETH_SWITCHBOARD_CONFIG),
            option::some(ETH_PYTH_CONFIG),
            option::some(ETH_SUPRA_CONFIG),
            ctx,
        );
        create_single_oracle<USDT>(
            &admin_cap,
            &mut oracle,
            6,
            option::some(USDT_SWITCHBOARD_CONFIG),
            option::some(USDT_PYTH_CONFIG),
            option::some(USDT_SUPRA_CONFIG),
            ctx,
        );
        create_single_oracle<USDC>(
            &admin_cap,
            &mut oracle,
            6,
            option::some(USDC_SWITCHBOARD_CONFIG),
            option::some(USDC_PYTH_CONFIG),
            option::some(USDC_SUPRA_CONFIG),
            ctx,
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

    public entry fun update_pyth_config<T>(
        _: &AdminCap,
        bucket_oracle: &mut BucketOracle,
        pyth_config: Option<address>,
    ) {
        let oracle = borrow_single_oracle_mut<T>(bucket_oracle);
        single_oracle::update_pyth_config(oracle, pyth_config);
    }

    public entry fun update_supra_config<T>(
        _: &AdminCap,
        bucket_oracle: &mut BucketOracle,
        supra_config: Option<u32>,
    ) {
        let oracle = borrow_single_oracle_mut<T>(bucket_oracle);
        single_oracle::update_supra_config(oracle, supra_config);
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

    public entry fun update_price<T>(
        bucket_oracle: &mut BucketOracle,
        clock: &Clock,
        switchboard_source: &Aggregator,
        supra_source: &OracleHolder,
        pair_id: u32,
    ) {
        let single_oracle = borrow_single_oracle_mut<T>(bucket_oracle);
        let price_collector = single_oracle::issue_price_collector<T>();
        single_oracle::collect_price_from_switchboard(single_oracle, &mut price_collector, switchboard_source);
        single_oracle::collect_price_from_supra(single_oracle, &mut price_collector, supra_source, pair_id);
        single_oracle::update_oracle_price(single_oracle, clock, price_collector);
    }

    #[test_only]
    public fun new_for_testing<T>(precision_decimal: u8, ctx: &mut TxContext): (BucketOracle, AdminCap) {
        let (oracle, admin_cap) = new_oracle(ctx);
        create_single_oracle<SUI>(
            &admin_cap,
            &mut oracle,
            precision_decimal,
            option::none(),
            option::none(),
            option::none(),
            ctx,
        );
        (oracle, admin_cap)
    }

    #[test_only]
    public fun share_for_testing<T>(precision_decimal: u8, admin: address, ctx: &mut TxContext) {
        let (oracle, admin_cap) = new_oracle(ctx);
        create_single_oracle<T>(
            &admin_cap,
            &mut oracle,
            precision_decimal,
            option::none(),
            option::none(),
            option::none(),
            ctx,
        );
        transfer::share_object(oracle);
        transfer::transfer(admin_cap, admin);
    }

    #[test_only]
    public fun update_price_for_testing<T>(bucket_oracle: &mut BucketOracle, price: u64) {
        let oracle = borrow_single_oracle_mut<T>(bucket_oracle);
        single_oracle::update_price_for_testing(oracle, price);
    }
}