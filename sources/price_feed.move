module bucket_oracle::price_feed {

    use sui::object::UID;
    use sui::tx_context::TxContext;
    use sui::object;

    friend bucket_oracle::oracle;

    struct PriceFeed<phantom T> has key, store {
        id: UID,
        price: u64,
        denominator: u64,
    }

    public(friend) fun new<T>(denominator: u64, ctx: &mut TxContext): PriceFeed<T> {
        PriceFeed { id: object::new(ctx), price: 0, denominator }
    }

    public fun get_price<T>(price_feed: &PriceFeed<T>): (u64, u64) {
        (price_feed.price, price_feed.denominator)
    }

    public(friend) fun update_price<T>(price_feed: &mut PriceFeed<T>, new_price: u64) {
        price_feed.price = new_price;
    }
}