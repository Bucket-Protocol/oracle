// SPDX-License-Identifier: MIT

/// Module manage StakedSui and validator list
module vsui::validator_set {
    use std::vector;
    use sui::object::{Self, UID};
    use sui::vec_map::{Self, VecMap};
    use sui::tx_context::{Self, TxContext};
    use sui::object_table::{Self, ObjectTable};
    use sui::table::{Self, Table};
    use sui::sui::{SUI};
    use sui_system::sui_system::{Self, SuiSystemState};
    use sui::event;
    use sui::balance::{Self, Balance};
    use sui_system::staking_pool::{Self, StakedSui};

    #[test_only]
    use sui::transfer;

    friend vsui::native_pool;
    
    const MIST_PER_SUI: u64 = 1_000_000_000;
    const MAX_VLDRS_UPDATE: u64 = 16;

    /* Errors definition */

    const E_NO_ACTIVE_VLDRS: u64 = 300;
    const E_BAD_ARGS: u64 = 301;
    const E_BAD_CONDITION: u64 = 302;
    const E_NOT_FOUND: u64 = 303;
    const E_TOO_MANY_VLDRS: u64 = 304;

    /* Events */
    struct ValidatorsSorted has copy, drop {
        validators: vector<address>
    }

    struct ValidatorPriorUpdated has copy, drop {
        validator: address,
        priority: u64
    }

    /* Objects */
    struct Vault has store {
        stakes: ObjectTable<u64, StakedSui>,
        gap: u64,
        length: u64,
        total_staked: u64,
    }
    
    // ValidatorSet object
    struct ValidatorSet has key, store {
        id: UID,
        vaults: Table<address, Vault>, // validator => Vault
        validators: VecMap<address, u64>,
        sorted_validators: vector<address>,
        is_sorted: bool,
    }

    
}