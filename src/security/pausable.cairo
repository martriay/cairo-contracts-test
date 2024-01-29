// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v1.0.3-rc.10 (security/pausable.cairo)

/// # Pausable Component
///
/// The Pausable component allows the using contract to implement an
/// emergency stop mechanism. Only functions that call `assert_paused`
/// or `assert_not_paused` will be affected by this mechanism.
#[starknet::component]
mod PausableComponent {
    use openzeppelin::security::interface::IPausable;

    use starknet::ContractAddress;
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        Pausable_paused: bool
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Paused: Paused,
        Unpaused: Unpaused,
    }

    /// Emitted when the pause is triggered by `account`.
    #[derive(Drop, starknet::Event)]
    struct Paused {
        account: ContractAddress
    }

    /// Emitted when the pause is lifted by `account`.
    #[derive(Drop, starknet::Event)]
    struct Unpaused {
        account: ContractAddress
    }

    mod Errors {
        const PAUSED: felt252 = 'Pausable: paused';
        const NOT_PAUSED: felt252 = 'Pausable: not paused';
    }

    #[embeddable_as(PausableImpl)]
    impl Pausable<
        TContractState, +HasComponent<TContractState>
    > of IPausable<ComponentState<TContractState>> {
        /// Returns true if the contract is paused, and false otherwise.
        fn is_paused(self: @ComponentState<TContractState>) -> bool {
            self.Pausable_paused.read()
        }
    }

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        /// Makes a function only callable when the contract is not paused.
        fn assert_not_paused(self: @ComponentState<TContractState>) {
            assert(!self.Pausable_paused.read(), Errors::PAUSED);
        }

        /// Makes a function only callable when the contract is paused.
        fn assert_paused(self: @ComponentState<TContractState>) {
            assert(self.Pausable_paused.read(), Errors::NOT_PAUSED);
        }

        /// Triggers a stopped state.
        ///
        /// Requirements:
        ///
        /// - The contract is not paused.
        ///
        /// Emits a `Paused` event.
        fn _pause(ref self: ComponentState<TContractState>) {
            self.assert_not_paused();
            self.Pausable_paused.write(true);
            self.emit(Paused { account: get_caller_address() });
        }

        /// Lifts the pause on the contract.
        ///
        /// Requirements:
        ///
        /// - The contract is paused.
        ///
        /// Emits an `Unpaused` event.
        fn _unpause(ref self: ComponentState<TContractState>) {
            self.assert_paused();
            self.Pausable_paused.write(false);
            self.emit(Unpaused { account: get_caller_address() });
        }
    }
}
