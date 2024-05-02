module volo::native_pool {

    use sui::coin::CoinMetadata;
    use volo::cert::CERT;

    public struct NativePool has key {
        id: UID,
    }

    public fun from_shares(
        _native_pool: &NativePool,
        _metadata: &CoinMetadata<CERT>,
        _shares: u64,
    ): u64 {
        abort 0
    }

}
