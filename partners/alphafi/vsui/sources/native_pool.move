// SPDX-License-Identifier: MIT

/// Pool allows exchange SUI for CERT and request to exchange it back at a possibly better rate.
/// 
/// Glossary:
/// * instant unstake - unstake when user can burn tokens and receive SUI in the same epoch
/// * active stake - StakedSui staked during previous epochs
module vsui::native_pool {
    use std::vector;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::sui::{SUI};
    use sui::balance::{Self};
    use sui::coin::{Self, Coin};
    use sui::event;
    use sui::table::{Self, Table};
    use sui::clock::{Self, Clock};
    use sui_system::sui_system::{Self, SuiSystemState};
    use vsui::cert::{Self, CERT, Metadata};
    use vsui::validator_set::{Self, ValidatorSet};
    use vsui::unstake_ticket::{Self, UnstakeTicket};

    // Track the current version of the module, iterate each upgrade
    const VERSION: u64 = 1;
    const ONE_SUI: u64 = 1_000_000_000;
    const MAX_PERCENT: u64 = 100_00; // represent 100.00%, used in threshold and percent calculation
    const REWARD_UPDATE_DELAY: u64 = 43_200_000; // 12h * 60m * 60s * 1000ms
    const MAX_UINT_64: u64 = 18_446_744_073_709_551_615;

    /* Errors definition, namespace=100 */

    // Calling functions from the wrong package version
    const E_INCOMPATIBLE_VERSION: u64 = 1;

    const E_MIN_LIMIT: u64 = 100;
    // Calling functions while pool is paused
    const E_PAUSED: u64 = 101;
    const E_LIMIT_TOO_LOW: u64 = 102;
    const E_NOTHING_TO_UNSTAKE: u64 = 103;
    const E_TICKET_LOCKED: u64 = 104;
    const E_LESS_REWARDS: u64 = 105;
    const E_DELAY_NOT_REACHED: u64 = 106;
    const E_REWARD_NOT_IN_THRESHOLD: u64 = 107;
    const E_BAD_SHARES: u64 = 108;
    const E_TOO_BIG_PERCENT: u64 = 109;
    const E_NOT_ENOUGH_BALANCE: u64 = 110;

    /* Events */
    struct StakedEvent has copy, drop {
        staker: address,
        sui_amount: u64,
        cert_amount: u64,
    }

    struct UnstakedEvent has copy, drop {
        staker: address,
        cert_amount: u64,
        sui_amount: u64
    }

    struct MinStakeChangedEvent has copy, drop {
        prev_value: u64,
        new_value: u64
    }

    struct UnstakeFeeThresholdChangedEvent has copy, drop {
        prev_value: u64,
        new_value: u64,
    }

    struct BaseUnstakeFeeChangedEvent has copy, drop {
        prev_value: u64,
        new_value: u64,
    }

    struct BaseRewardFeeChangedEvent has copy, drop {
        prev_value: u64,
        new_value: u64,
    }

    struct RewardsThresholdChangedEvent has copy, drop {
        prev_value: u64,
        new_value: u64,
    }

    struct RewardsUpdated has copy, drop {
        value: u64,
    }

    struct StakedUpdated has copy, drop {
        total_staked: u64,
        epoch: u64,
    }

    struct FeeCollectedEvent has copy, drop {
        to: address,
        value: u64
    }

    struct PausedEvent has copy, drop {
        paused: bool
    }

    struct MigratedEvent has copy, drop {
        prev_version: u64,
        new_version: u64,
    }

    struct RatioUpdatedEvent has copy, drop {
        ratio: u256,

    }

    /* Objects */
    
    // Liquid staking pool object
    struct NativePool has key {
        id: UID,

        pending: Coin<SUI>, // pending SUI that should be staked
        collectable_fee: Coin<SUI>, // owner fee
        validator_set: ValidatorSet, // pool validator set
        ticket_metadata: unstake_ticket::Metadata,

        /* Store active stake of each epoch */
        total_staked: Table<u64, u64>,
        staked_update_epoch: u64,

        /* Fees */
        base_unstake_fee: u64, // percent of fee per 1 SUI
        unstake_fee_threshold: u64, // percent of active stake
        base_reward_fee: u64, // percent of rewards

        /* Access */
        version: u64,
        paused: bool,

        /* Limits */
        min_stake: u64, // all stakes should be greater than

        /* General stats */
        total_rewards: u64, // current rewards of pool, we can't calculate them, because it's impossible to do on current step
        collected_rewards: u64, // rewards that stashed as protocol fee

        /* Thresholds */
        rewards_threshold: u64, // percent of rewards that possible to increase
        rewards_update_ts: u64, // timestamp when we updated rewards last time
    }

    

    
    // exchange SUI to CERT, add SUI to pending and try to stake pool
    public fun stake_non_entry(_self: &mut NativePool, _metadata: &mut Metadata<CERT>, _wrapper: &mut SuiSystemState, _coin: Coin<SUI>, _ctx: &mut TxContext): Coin<CERT> {
        abort 0
    }

    public fun get_min_stake(_self: &NativePool): u64{
        abort 0
    }

    public fun from_shares(_self: &NativePool, _metadata: &Metadata<CERT>, _shares: u64): u64 {
        abort 0
    }

    public fun to_shares(_self: &NativePool, _metadata: &Metadata<CERT>, _amount: u64): u64 {
        abort 0
    }
}