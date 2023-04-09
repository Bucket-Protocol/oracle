module bucket_oracle::oracle {
    
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_object_field as dof;
    use sui::sui::SUI;

    use bucket_oracle::price_feed::{Self, PriceFeed};

    struct AdminCap has key { id: UID }

    struct BucketOracle has key { id: UID }

    struct PriceFeedType<phantom T> has copy, drop, store {}

    fun init(ctx: &mut TxContext) {
        let (oracle, admin_cap) = new_oracle(ctx);
        create_price_feed<SUI>(&admin_cap, &mut oracle, 1000000, ctx);
        update_price<SUI>(&admin_cap, &mut oracle, 10000000000);
        transfer::transfer(admin_cap, tx_context::sender(ctx));
        transfer::share_object(oracle);
    }

    fun new_oracle(ctx: &mut TxContext): (BucketOracle, AdminCap) {
        (BucketOracle { id: object::new(ctx) }, AdminCap { id: object::new(ctx) })
    }

    public fun create_price_feed<T>(
        _: &AdminCap,
        oracle: &mut BucketOracle,
        denominator: u64,
        ctx: &mut TxContext
    ) {
        dof::add<PriceFeedType<T>, PriceFeed<T>>(
            &mut oracle.id,
            PriceFeedType<T> {}, 
            price_feed::new(denominator, ctx),
        );
    }

    public fun get_price<T>(oracle: &BucketOracle): (u64, u64) {
        price_feed::get_price<T>(get_price_feed(oracle))
    }

    public fun update_price<T>(_: &AdminCap, oracle: &mut BucketOracle, new_price: u64) {
        price_feed::update_price<T>(get_price_feed_mut(oracle), new_price);
    }

    fun get_price_feed<T>(oracle: &BucketOracle): &PriceFeed<T> {
        dof::borrow<PriceFeedType<T>, PriceFeed<T>>(&oracle.id, PriceFeedType<T> {})
    }

    fun get_price_feed_mut<T>(oracle: &mut BucketOracle): &mut PriceFeed<T> {
        dof::borrow_mut<PriceFeedType<T>, PriceFeed<T>>(&mut oracle.id, PriceFeedType<T> {})
    }

    #[test_only]
    public fun new_for_testing<T>(denominator: u64, ctx: &mut TxContext): (BucketOracle, AdminCap) {
        let (oracle, admin_cap) = new_oracle(ctx);
        create_price_feed<T>(&admin_cap, &mut oracle, denominator, ctx);
        (oracle, admin_cap)
    }

    #[test]
    fun test_price_feed(): (BucketOracle, AdminCap) {
        use sui::test_random;
        use sui::test_scenario;
        use std::vector;
        use std::debug;
        
        let dev = @0xde1;

        let scenario_val = test_scenario::begin(dev);
        let scenario = &mut scenario_val;

        let init_denominator = 1000000;
        let (oracle, admin_cap) = new_for_testing<SUI>(init_denominator, test_scenario::ctx(scenario));

        let loop_count = 10;
        let seed = b"bucket oracle";
        vector::push_back(&mut seed, loop_count);
        let rang = test_random::new(seed);
        let rangr = &mut rang;

        let counter = 0;
        while(counter < loop_count) {
            test_scenario::next_tx(scenario, dev);
            {
                let new_price = test_random::next_u64(rangr) % 100000000;
                update_price<SUI>(&admin_cap, &mut oracle, new_price);
                let (price_fetched, denominator_fetched) = get_price<SUI>(&oracle);
                debug::print(&price_fetched);
                assert!(price_fetched == new_price, 0);
                assert!(denominator_fetched == init_denominator, 0);
            };
            
            counter = counter + 1;
        };

        test_scenario::end(scenario_val);

        (oracle, admin_cap)
    }
}