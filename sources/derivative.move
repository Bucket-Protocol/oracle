module bucket_oracle::derivative {
    
    use sui::clock::{Self, Clock};

    const TOLERANCE_MS_OF_GET_RATE: u64 = 10_000;
    const RATE_PRECISSION: u64 = 1_000_000_000;

    const ERateOutdated: u64 = 0;

    struct DerivativeKey<phantom A, phantom D> has copy, drop, store {}

    struct PermissionKey<phantom A, phantom D, phantom W: drop> has copy, drop, store {}

    struct ExchangeRate<phantom A, phantom D> has store {
        latest_update_ms: u64, 
        exchange_rate: u64,
    }

    struct Permission<phantom A, phantom D, phantom W: drop> has store {}

    public fun update_rate<T, W: drop>(
        _witness: &W,
        clock: &Clock,
        rate_obj: &mut ExchangeRate<T, W>,
        new_rate: u64,
    ) {
        rate_obj.exchange_rate = new_rate;
        rate_obj.latest_update_ms = clock::timestamp_ms(clock);
    }

    public fun get_exchange_rate<A, D>(
        clock: &Clock,
        rate_obj: &ExchangeRate<A, D>,
    ): u64 {
        assert!(
            rate_obj.latest_update_ms <= clock::timestamp_ms(clock) + TOLERANCE_MS_OF_GET_RATE,
            ERateOutdated,
        );
        rate_obj.exchange_rate
    }

    public fun get_rate_precision(): u64 { RATE_PRECISSION }

    public(friend) fun new_derivative<A, D>(): (DerivativeKey<A, D>, ExchangeRate<A, D>) {
        (
            DerivativeKey<A, D> {},
            ExchangeRate<A, D> {
                latest_update_ms: 0,
                exchange_rate: 0,
            },
        )
    }

    public(friend) fun new_permission<A, D, W: drop>(): (PermissionKey<A, D, W>, Permission<A, D, W>) {
        (
            PermissionKey<A, D, W> {},
            Permission<A, D, W> {},
        )
    }
}