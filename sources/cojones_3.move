/*
/// Module: cojones_3
module cojones_3::cojones_3;
*/

module cojones_3::time_locked_vault {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::clock::{Self, Clock};
    use sui::sui::SUI;
    use sui::event;
    use std::debug;

    const CONSTANT_AMOUNT: u64 = 1000000000; // 1 SUI (in MIST, 1 SUI = 10^9 MIST)

    // Struct to represent a time-locked vault
    struct TimeLockedVault has key {
        id: UID,
        balance: Balance<SUI>,
        unlock_time: u64, // Unix timestamp in seconds
    }

    // Event emitted when funds are deposited
    struct FundsDeposited has copy, drop, store {
        _amount: u64,
        _depositor: address,
    }

    // Event emitted when funds are withdrawn
    struct FundsWithdrawn has copy, drop {
        amount: u64,
        recipient: address,
    }


    // Initialize a new time-locked vault
    public fun create_vault(ctx: &mut TxContext) {
        let vault = TimeLockedVault {
            id: object::new(ctx),
            balance: balance::zero(),
            unlock_time: 0,
        };
        transfer::transfer(vault, tx_context::sender(ctx));
    }

    // Deposit SUI into the vault
    public fun deposit(coin: Coin<SUI>, clock: &Clock, ctx: &mut TxContext) : sui::object::ID {
        let _amount = coin::value(&coin);
        let _depositor = tx_context::sender(ctx);
	let vault = TimeLockedVault {
            id: object::new(ctx),
            balance: balance::zero(),
            unlock_time: 0,
        };
        


        // Add the coin to the vault's balance
        balance::join(&mut vault.balance, coin::into_balance(coin));

        // Set the unlock time to 200 secs now
        vault.unlock_time = clock::timestamp_ms(clock) / 1000 + 200;
	vault.unlock_time = tx_context::timestamp_ms(ctx) / 1000 + 200;
        //vault.unlock_time = ctx.timestamp_ms() / 1000 + 200; // lock for 200 seconds

        // Emit a FundsDeposited event
        // delete this:event::emit(TimeEvent { timestamp_ms: ctx.epoch_timestamp_ms() });
        let ret_id = object::id(&vault);
        transfer::transfer(vault, tx_context::sender(ctx));
        event::emit(FundsDeposited {_amount, _depositor });
	let test_msg = &b"aaa!!!!!!!!!!!!!!!!!!!";
	std::debug::print(test_msg);
	//std::debug::print(&b"test test:".to_string());
	std::debug::print(&ret_id);
        ret_id
    }

    // Withdraw SUI from the vault after the unlock time has passed
    public entry fun withdraw(vault: &mut TimeLockedVault, clock: &Clock, ctx: &mut TxContext) {
        let recipient = tx_context::sender(ctx);
        let current_time = clock::timestamp_ms(clock) / 1000;

        // Ensure the unlock time has passed
        assert!(current_time >= vault.unlock_time, 0,); // Funds are still locked

        // Get the balance from the vault
        let amount = balance::value(&vault.balance);
        let coin = coin::take(&mut vault.balance, amount, ctx);

        // Transfer the coin to the recipient
        transfer::public_transfer(coin, recipient);

        // Emit a FundsWithdrawn event
        event::emit(FundsWithdrawn {
            amount,
            recipient,
        });
    }
}