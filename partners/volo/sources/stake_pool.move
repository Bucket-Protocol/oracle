module volo::stake_pool {

    use volo::cert::Metadata;
    use volo::cert::CERT;

    public struct StakePool has store, key {
        id: UID,
    }

    public fun lst_amount_to_sui_amount(
        _native_pool: &StakePool,
        _metadata: &Metadata<CERT>,
        _shares: u64,
    ): u64 {
        abort 0
    }
}
