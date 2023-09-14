//
// Ownable module
//
// Allows for having a single owner of a contract
//
// Providers these basic utility functions:
//
// - assert_owner(address: ContractAddress)
// - get_owner() -> ContractAddress
// - set_owner(address: ContractAddress)
// - transfer_ownership(address: ContractAddress)
//
// Functions for two step transfer:
//
// - nominate_owner(address: ContractAddress)
// - reset_nomination()
// - accept_nomination()
// - renounce_nomination()
//
mod ownable {
    use starknet::{ContractAddress, get_caller_address};

    fn assert_owner(address: ContractAddress) {
        assert(internal::read_owner() == address, 'not owner');
    }

    fn get_owner() -> ContractAddress {
        internal::read_owner()
    }

    fn set_owner(address: ContractAddress) {
        internal::write_owner(address);
    }

    fn transfer_ownership(address: ContractAddress) {
        assert_owner(get_caller_address());
        internal::write_owner(address);
    }

    //
    // two step ownership transfer
    //

    fn nominate_owner(address: ContractAddress) {
        assert_owner(get_caller_address());
        internal::write_nominee(address);
    }

    fn reset_nomination() {
        assert_owner(get_caller_address());
        internal::write_nominee(Zeroable::zero());
    }

    fn accept_nomination() {
        let nominee = get_caller_address();
        assert(internal::read_nominee() == nominee, 'not nominee');
        internal::write_owner(nominee);
        internal::write_nominee(Zeroable::zero());
    }

    fn renounce_nomination() {
        assert(internal::read_nominee() == get_caller_address(), 'not nominee');
        internal::write_nominee(Zeroable::zero());
    }

    //
    // Internal functions
    //

    mod internal {
        use starknet::{ContractAddress, SyscallResult, SyscallResultTrait};
        use starknet::storage_access::{StorageBaseAddress, Store, storage_base_address_from_felt252};

        const ADDRESS_DOMAIN: u32 = 0;

        fn owner_storage_address() -> StorageBaseAddress {
            storage_base_address_from_felt252(selector!("__auth_ownable_owner"))
        }

        fn nominee_storage_address() -> StorageBaseAddress {
            storage_base_address_from_felt252(selector!("__auth_ownable_nominee"))
        }

        fn read_owner() -> ContractAddress {
            Store::<ContractAddress>::read(ADDRESS_DOMAIN, owner_storage_address()).unwrap_syscall()
        }

        fn write_owner(owner: ContractAddress) {
            Store::<ContractAddress>::write(ADDRESS_DOMAIN, owner_storage_address(), owner).unwrap_syscall();
        }

        fn read_nominee() -> ContractAddress {
            Store::<ContractAddress>::read(ADDRESS_DOMAIN, nominee_storage_address()).unwrap_syscall()
        }

        fn write_nominee(nominee: ContractAddress) {
            Store::<ContractAddress>::write(ADDRESS_DOMAIN, nominee_storage_address(), nominee).unwrap_syscall();
        }
    }
}

// TODO: tests
