#[test_only]
module cojones_3::time_locked_vault_tests
{
   //import the module
   use cojones_3::time_locked_vault;

    use sui::test_scenario;
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::tx_context::{Self, TxContext};


   #[test]
   fun test_deposit() {
        let scenario = test_scenario::begin(@0x123); // Start a test scenario
        let ctx = test_scenario::ctx(&mut scenario);

        // Create a vault
        time_locked_vault::create_vault(ctx);
        let vault = test_scenario::take_from_sender<time_locked_vault::TimeLockedVault>(&scenario);
        
        // Mint some SUI for testing
        let coin: Coin<SUI> = coin::mint(100, ctx);

        // Deposit SUI into the vault
        time_locked_vault::deposit(&mut vault, coin, clock::mock(), ctx);

        // Check that the vault's balance is updated
        assert!(balance::value(&vault.balance) == 100, 0);

        //test_scenario::return_owned(vault);
        test_scenario::end(scenario);

   }
}


/*
module cojones_3::time_locked_vault_tests {
    use sui::test_scenario;
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::tx_context::{Self, TxContext};

    use my_module::time_locked_vault;

    // Test creating a vault and depositing funds
    #[test]
    fun test_deposit() {
        let scenario = test_scenario::begin(@0x123); // Start a test scenario
        let ctx = test_scenario::ctx(&mut scenario);

        // Create a vault
        time_locked_vault::create_vault(ctx);
        let vault = test_scenario::take_owned<time_locked_vault::TimeLockedVault>(&scenario);

        // Mint some SUI for testing
        let coin: Coin<SUI> = coin::mint(100, ctx);

        // Deposit SUI into the vault
        time_locked_vault::deposit(&mut vault, coin, clock::mock(), ctx);

        // Check that the vault's balance is updated
        assert!(balance::value(&vault.balance) == 100, 0, "Vault balance should be 100");

        test_scenario::return_owned(vault);
        test_scenario::end(scenario);
    }

    // Test withdrawing funds after the unlock time
    #[test]
    fun test_withdraw_after_unlock_time() {
        let scenario = test_scenario::begin(@0x123); // Start a test scenario
        let ctx = test_scenario::ctx(&mut scenario);

        // Create a vault
        time_locked_vault::create_vault(ctx);
        let vault = test_scenario::take_owned<time_locked_vault::TimeLockedVault>(&scenario);

        // Mint some SUI for testing
        let coin: Coin<SUI> = coin::mint(100, ctx);

        // Deposit SUI into the vault
        time_locked_vault::deposit(&mut vault, coin, clock::mock(), ctx);

        // Fast-forward time by 1 year + 1 second
        let clock = clock::mock_with_timestamp(31536001000); // 1 year + 1 second in milliseconds

        // Withdraw funds
        time_locked_vault::withdraw(&mut vault, &clock, ctx);

        // Check that the vault's balance is zero
        assert!(balance::value(&vault.balance) == 0, 0, "Vault balance should be 0");

        test_scenario::return_owned(vault);
        test_scenario::end(scenario);
    }

    // Test withdrawing funds before the unlock time (should fail)
    #[test]
    #[expected_failure(abort_code = 0)]
    fun test_withdraw_before_unlock_time() {
        let scenario = test_scenario::begin(@0x123); // Start a test scenario
        let ctx = test_scenario::ctx(&mut scenario);

        // Create a vault
        time_locked_vault::create_vault(ctx);
        let vault = test_scenario::take_owned<time_locked_vault::TimeLockedVault>(&scenario);

        // Mint some SUI for testing
        let coin: Coin<SUI> = coin::mint(100, ctx);

        // Deposit SUI into the vault
        time_locked_vault::deposit(&mut vault, coin, clock::mock(), ctx);

        // Try to withdraw funds immediately (before unlock time)
        time_locked_vault::withdraw(&mut vault, clock::mock(), ctx);

        test_scenario::return_owned(vault);
        test_scenario::end(scenario);
    }
}*/