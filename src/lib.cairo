mod ownable {
    use starknet::{ContractAddress};

    fn assert_owner(address: ContractAddress) {
        let owner = internal::read_owner();
        assert(owner == address, 'not owner');
    }

    fn get_owner() -> ContractAddress {
        internal::read_owner()
    }

    fn set_owner(address: ContractAddress) {
        internal::write_owner(address);
    }

    mod internal {
        use starknet::{ContractAddress, SyscallResult, SyscallResultTrait};
        use starknet::storage_access::{StorageBaseAddress, Store, storage_base_address_from_felt252};

        const ADDRESS_DOMAIN: u32 = 0;

        fn owner_storage_address() -> StorageBaseAddress {
            storage_base_address_from_felt252(selector!("__auth_ownable_owner"))
        }

        fn read_owner() -> ContractAddress {
            Store::<ContractAddress>::read(ADDRESS_DOMAIN, owner_storage_address()).unwrap_syscall()
        }

        fn write_owner(owner: ContractAddress) {
            Store::<ContractAddress>::write(ADDRESS_DOMAIN, owner_storage_address(), owner).unwrap_syscall();
        }
    }
}

// TODO: tests