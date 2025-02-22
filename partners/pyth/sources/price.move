module pyth::price {
    use pyth::i64::I64;

    struct Price has copy, drop, store {
        price: I64,
        /// Confidence interval around the price
        conf: u64,
        /// The exponent
        expo: I64,
        /// Unix timestamp of when this price was computed
        timestamp: u64,
    }

    public fun new(price: I64, conf: u64, expo: I64, timestamp: u64): Price {
        Price {
            price: price,
            conf: conf,
            expo: expo,
            timestamp: timestamp,
        }
    }

    public fun get_price(price: &Price): I64 {
        price.price
    }

    public fun get_conf(price: &Price): u64 {
        price.conf
    }

    public fun get_timestamp(price: &Price): u64 {
        price.timestamp
    }

    public fun get_expo(price: &Price): I64 {
        price.expo
    }
}
