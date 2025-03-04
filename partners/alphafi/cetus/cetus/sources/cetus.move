#[allow(lint(self_transfer))]
module cetus::cetus {
    use sui::balance::{Self, Balance};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::coin::{Self, Coin};
    use sui::clock::{Clock};
    
    use cetus_clmm::config::{GlobalConfig};
    use cetus_clmm::pool::{Self, Pool};
    use cetus_clmm::position::{Self, Position};
    use cetus_clmm::rewarder::{RewarderGlobalVault};
    // use 0x06864a6f921804860930db6ddbe2e16acdf8504495ea7481637a1c8b9a8fe54b::cetus::CETUS;
    // use 0x2::sui::SUI;



    struct Details has key {
        id: UID,
        lower_sqrt_price: u256,
        upper_sqrt_price: u256
    }


    fun init(ctx: &mut TxContext) {
        let details = Details {
            id: object::new(ctx),
            lower_sqrt_price: 18446744073709551616,
            upper_sqrt_price: 18454123878217468680
        };

        transfer::share_object(details);
    }


    public fun update_details(
        details: &mut Details,
        lower_sqrt_price: u256,
        upper_sqrt_price: u256
    ) {
        details.lower_sqrt_price = lower_sqrt_price;
        details.upper_sqrt_price = upper_sqrt_price;
    }

    // Swap
    public fun swap_a2b<CoinTypeA, CoinTypeB>(
        config: &GlobalConfig,
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        coin_a: Coin<CoinTypeA>,
        by_amount_in: bool,
        amount: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        let coin_b = coin::zero<CoinTypeB>(ctx);
        let sqrt_price_limit = 4295048016;

        let (receive_a, receive_b, flash_receipt) = pool::flash_swap<CoinTypeA, CoinTypeB>(
            config,
            pool,
            true,
            by_amount_in,
            amount,
            sqrt_price_limit,
            clock
        );
        let in_amount = pool::swap_pay_amount(&flash_receipt);


        // pay for flash swap
        let pay_coin_a = coin::into_balance(coin::split(&mut coin_a, in_amount, ctx));
        let pay_coin_b = balance::zero<CoinTypeB>();

        coin::join(&mut coin_b, coin::from_balance(receive_b, ctx));
        coin::join(&mut coin_a, coin::from_balance(receive_a, ctx));

        pool::repay_flash_swap<CoinTypeA, CoinTypeB>(
            config,
            pool,
            pay_coin_a,
            pay_coin_b,
            flash_receipt
        );

        // ... send coins
        // transfer::public_transfer(coin_a, tx_context::sender(ctx));
        // transfer::public_transfer(coin_b, tx_context::sender(ctx));
        (coin_a, coin_b)

    }

    public fun swap_b2a<CoinTypeA, CoinTypeB>(
        config: &GlobalConfig,
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        coin_b: Coin<CoinTypeB>,
        by_amount_in: bool,
        amount: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        let coin_a = coin::zero<CoinTypeA>(ctx);
        let sqrt_price_limit = 79226673515401279992447579055;

        let (receive_a, receive_b, flash_receipt) = pool::flash_swap<CoinTypeA, CoinTypeB>(
            config,
            pool,
            false,
            by_amount_in,
            amount,
            sqrt_price_limit,
            clock
        );
        let in_amount = pool::swap_pay_amount(&flash_receipt);


        // pay for flash swap
        let pay_coin_a = balance::zero<CoinTypeA>();
        let pay_coin_b = coin::into_balance(coin::split(&mut coin_b, in_amount, ctx));

        coin::join(&mut coin_b, coin::from_balance(receive_b, ctx));
        coin::join(&mut coin_a, coin::from_balance(receive_a, ctx));

        pool::repay_flash_swap<CoinTypeA, CoinTypeB>(
            config,
            pool,
            pay_coin_a,
            pay_coin_b,
            flash_receipt
        );

        // ... send coins
        // transfer::public_transfer(coin_a, tx_context::sender(ctx));
        // transfer::public_transfer(coin_b, tx_context::sender(ctx));

        (coin_a, coin_b)

    }
    


    

    public entry fun open_position_with_liquidity_with_all<CoinTypeA, CoinTypeB>(
        config: &GlobalConfig,
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        tick_lower_idx: u32,
        tick_upper_idx: u32,
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,
        amount_a: u64,
        amount_b: u64,
        fix_amount_a: bool,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let position_nft = pool::open_position(
            config,
            pool,
            tick_lower_idx,
            tick_upper_idx,
            ctx
        );
        let amount = if (fix_amount_a) amount_a else amount_b;
        let receipt = pool::add_liquidity_fix_coin(
            config,
            pool,
            &mut position_nft,
            amount,
            fix_amount_a,
            clock
        );

        let (amount_0, amount_1) = pool::add_liquidity_pay_amount(&receipt);


        // let sqrt_price = pool::current_sqrt_price(&pool);



        let balance_a = coin::into_balance<CoinTypeA>(coin::split(&mut coin_a, amount_0, ctx));
        let balance_b = coin::into_balance<CoinTypeB>(coin::split(&mut coin_b, amount_1, ctx));
        pool::repay_add_liquidity(config, pool, balance_a, balance_b, receipt);

        transfer::public_transfer(position_nft, tx_context::sender(ctx));
        transfer::public_transfer(coin_a, tx_context::sender(ctx));
        transfer::public_transfer(coin_b, tx_context::sender(ctx));
    }

    public fun add_liquidity<CoinTypeA, CoinTypeB>(
        config: &GlobalConfig,
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        position_nft: &mut Position,
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,
        amount_a: u64,
        amount_b: u64,
        fix_amount_a: bool,
        clock: &Clock
    ) {
        let amount = if (fix_amount_a) amount_a else amount_b;
        let receipt = pool::add_liquidity_fix_coin(
            config,
            pool,
            position_nft,
            amount,
            fix_amount_a,
            clock
        );

        let (amount_0, amount_1) = pool::add_liquidity_pay_amount(&receipt);
        assert!(amount_1 == amount_b, 1);

        let balance_a = coin::into_balance<CoinTypeA>(coin_a);
        let balance_b = coin::into_balance<CoinTypeB>(coin_b);
        pool::repay_add_liquidity(config, pool, balance_a, balance_b, receipt);

    }


    public entry fun collect_rewards_and_reinvest<CoinTypeA, CoinTypeB, CETUS, SUI>(
        config: &GlobalConfig,
        details: &mut Details,
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        cetus_sui_pool: &mut Pool<CETUS, SUI>,
        coina_sui_pool: &mut Pool<CoinTypeA, SUI>,
        coinb_sui_pool: &mut Pool<CoinTypeB, SUI>,
        position_nft: &mut Position,
        vault: &mut RewarderGlobalVault,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let cetus_reward_balance = pool::collect_reward<CoinTypeA, CoinTypeB, CETUS>(
            config,
            pool,
            position_nft,
            vault,
            true,
            clock
        );
        let cetus_reward = coin::from_balance(cetus_reward_balance, ctx);
        let sui_reward_balance = pool::collect_reward<CoinTypeA, CoinTypeB, SUI>(
            config,
            pool,
            position_nft,
            vault,
            true,
            clock
        );
        let sui_reward = coin::from_balance(sui_reward_balance, ctx);
        let cetus_amount = coin::value(&cetus_reward);
        
        let (rem_cetus_coin, sui_coin) = swap_a2b<CETUS, SUI>(
            config,
            cetus_sui_pool,
            cetus_reward,
            true,
            cetus_amount,
            clock,
            ctx
        );

        coin::destroy_zero(rem_cetus_coin);
        coin::join<SUI>(&mut sui_reward, sui_coin);

        let current_sqrt_price = (pool::current_sqrt_price<CoinTypeA, CoinTypeB>(pool) as u256);
        let lower_sqrt_price = details.lower_sqrt_price;
        let upper_sqrt_price = details.upper_sqrt_price;
        let range = upper_sqrt_price - lower_sqrt_price;

        let sui_val = (coin::value(&sui_reward) as u256);
        let to_coina = (sui_val * (upper_sqrt_price - current_sqrt_price)) / range;
        let to_coinb = sui_val - to_coina;



        let (coin_a, rem_sui_reward) = swap_b2a<CoinTypeA, SUI>(
            config,
            coina_sui_pool,
            sui_reward,
            true,
            (to_coina as u64),
            clock,
            ctx
        );

        let (coin_b, rem_rem_sui_reward) = swap_b2a<CoinTypeB, SUI> (
            config,
            coinb_sui_pool,
            rem_sui_reward,
            true,
            (to_coinb as u64),
            clock,
            ctx
        );

        coin::destroy_zero(rem_rem_sui_reward);
        let amount_a = coin::value(&coin_a);
        let amount_b = coin::value(&coin_b);

        add_liquidity(config, pool, position_nft, coin_a, coin_b, amount_a, amount_b, true, clock);
                
    }



    public entry fun collect_fee<CoinTypeA, CoinTypeB>(
        config: &GlobalConfig,
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        position: &mut Position,
        ctx: &mut TxContext,
    ) {
        let (balance_a, balance_b) = pool::collect_fee<CoinTypeA, CoinTypeB>(config, pool, position, true);
        transfer::public_transfer(coin::from_balance<CoinTypeA>(balance_a, ctx), tx_context::sender(ctx));
        transfer::public_transfer(coin::from_balance<CoinTypeB>(balance_b, ctx), tx_context::sender(ctx));
    }




    public entry fun remove_liquidity<CoinTypeA, CoinTypeB>(
        config: &GlobalConfig,
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        position_nft: &mut Position,
        delta_liquidity: u128,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        // get_liquidity_from_amount
        let (balance_a, balance_b) = pool::remove_liquidity<CoinTypeA, CoinTypeB>(
            config,
            pool,
            position_nft,
            delta_liquidity,
            clock
        );

        let (fee_a, fee_b) = pool::collect_fee(
            config,
            pool,
            position_nft,
            false
        );

        // you can implentment these methods by yourself methods.
        balance::join(&mut balance_a, fee_a);
        balance::join(&mut balance_b, fee_b);
        transfer::public_transfer(coin::from_balance(balance_a, ctx), tx_context::sender(ctx));
        transfer::public_transfer(coin::from_balance(balance_b, ctx), tx_context::sender(ctx));
    }

    public entry fun close_position<CoinTypeA, CoinTypeB>(
        config: &GlobalConfig,
        pool: &mut Pool<CoinTypeA, CoinTypeB>,
        position_nft: Position,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let all_liquidity = position::liquidity(&mut position_nft);
        if(all_liquidity > 0) {
            remove_liquidity(
                config,
                pool,
                &mut position_nft,
                all_liquidity,
                clock,
                ctx
            );
        };
        pool::close_position<CoinTypeA, CoinTypeB>(config, pool, position_nft);
    }

}