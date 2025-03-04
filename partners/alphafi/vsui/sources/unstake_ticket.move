// SPDX-License-Identifier: MIT

module vsui::unstake_ticket {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::event;
    use sui::table::{Self, Table};

    friend vsui::native_pool;

    const VERSION: u64 = 1;

    /* Events */

    struct TicketMintedEvent has copy, drop {
        id: ID,
        value: u64, 
        unlock_epoch: u64,
        unstake_fee: u64,
    }

    struct TicketBurnedEvent has copy, drop {
        id: ID,
        value: u64,
        epoch: u64,
        unstake_fee: u64,
    }

    /* Objects */

    // Special ticket gives ability to make unstake of principal after timestamp
    struct UnstakeTicket has key {
        id: UID,
        unlock_epoch: u64, // epoch where ticket can burn
        value: u64, // value of SUI that should be paid for ticket
        unstake_fee: u64, // fee that we collect while burn
    }
    
    // Liquid staking pool object
    struct Metadata has key, store {
        id: UID,
        version: u64,
        total_supply: u64,
        max_history_value: Table<u64, u64>, // epoch => sum of tickets
    }
}