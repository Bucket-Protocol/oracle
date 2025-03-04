module 0x549e8b69270defbfafd4f94e17ec44cdbdd99820b33bda2278dea3b9a32d3f55::cert{

    use sui::object::{Self, UID};
    use sui::balance::{Self, Supply, Balance};
    struct CERT has drop {
        dummy_field: bool,
    }

    struct Metadata<phantom T> has key, store {
        id: UID,
        version: u64, // Track the current version of the shared object
        total_supply: Supply<T>,
    }
}