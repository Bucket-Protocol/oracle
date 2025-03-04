#[allow(lint(self_transfer))]
module alphafi_fungible::alphafi_bluefin_stsui_sui_ft_pool{
    use sui::clock::Clock;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin,TreasuryCap};
    use sui::event;
    use sui::package;
    use bluefin_spot::pool::{Pool as BluefinPool};
    use bluefin_spot::config::{GlobalConfig};
    use alphafi_fungible::alphafi_bluefin_stsui_sui_ft_investor::{Investor};
    use liquid_staking::liquid_staking::{LiquidStakingInfo};
    use sui_system::sui_system::{SuiSystemState};
    use lending_core::storage::{Storage as NaviStorage};
    use oracle::oracle::PriceOracle;
    

    // for precision.
    const MUL: u128 = 1000000000000000000000000000000000000;



    // single token pool(navi+scallop) object where T is the type of coin to be deposited
    public struct Pool<phantom T, phantom S, phantom FT> has key, store{
        id: UID,
        // total amount of tokens supplied.
        tokensInvested: u128,
        // fee to be charged for each deposit operation.
        deposit_fee: u64,
        deposit_fee_max_cap: u64,
        withdrawal_fee: u64,
        withdraw_fee_max_cap: u64,
        treasury_cap: TreasuryCap<FT>,
        paused: bool
    }

    public fun get_fungible_token_amounts<T, S, FT>(
        self: & Pool<T, S, FT>,
        investor: &mut Investor<T, S>,
        bluefin_pool: &BluefinPool<T,S>,
        amount: u64,
    ) : (u64, u64) {
        abort 0
    }

    public fun get_fungible_token_price<T, S, FT>(
        self: & Pool<T, S, FT>,
        investor: &mut Investor<T, S>,
        bluefin_pool:&BluefinPool<T,S>,
        oracle: &PriceOracle,
        storage: &mut NaviStorage,
        amount: u64,
        clock: &Clock
    ) : u256 {
        abort 0
    }

    
    
   
}
