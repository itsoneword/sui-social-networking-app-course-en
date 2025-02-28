module counter::counter {
 
    use sui::dynamic_field::{Self as df};
    use sui::event::emit;
 

    public struct CounterStorage has key {
        id: UID,
        // Track addresses and their counters
        addresses: vector<address>
    }

    public struct Counter has store {
        owner: address,
        times: u64
    }

    public struct CountEvent has copy, drop {
        storage_id: ID,
        owner: address,
        times: u64,
    }

    public struct MintEvent has copy, drop {
        storage_id: ID,
        owner: address,
        times: u64,
    }

    public struct BurnEvent has copy, drop {
        storage_id: ID,
        owner: address,
        times: u64,
    }

    // Admin capability for managing counters
    public struct AdminCap has key, store {
        id: UID
    }

    // New event for viewing addresses
    public struct ViewAddressesEvent has copy, drop {
        storage_id: ID,
        addresses: vector<address>
    }

    // New event for viewing counter value
    public struct ViewCounterEvent has copy, drop {
        storage_id: ID,
        owner: address,
        times: u64
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(CounterStorage {
            id: object::new(ctx),
            addresses: vector::empty()
        });
        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));
    }
       
    public entry fun create_counter(storage: &mut CounterStorage, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(!counter_exists(storage, sender), 0); // Ensure one counter per address
        
        // Add new counter as dynamic field
        df::add(&mut storage.id, sender, Counter { owner: sender, times: 0 });
        // Track the address
        vector::push_back(&mut storage.addresses, sender);
        
        emit(
            MintEvent {
                storage_id: object::uid_to_inner(&storage.id),
                owner: sender,
                times: 0,
            }
        );
    }

    public fun increment_counter(storage: &mut CounterStorage, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let storage_id = object::uid_to_inner(&storage.id);
        let counter = df::borrow_mut<address, Counter>(&mut storage.id, sender);
        counter.times = counter.times + 1;
        
        emit(
            CountEvent {
                storage_id,
                owner: sender,
                times: counter.times,
            }
        );
    }

    // Admin can remove any counter by address
    public entry fun admin_remove_counter(
        storage: &mut CounterStorage, 
        owner: address,
        _admin: &AdminCap
    ) {
        let Counter { owner, times } = df::remove(&mut storage.id, owner);
        // Remove from addresses list
        let (_, index) = vector::index_of(&storage.addresses, &owner);
        vector::remove(&mut storage.addresses, index);
        
        emit(
            BurnEvent {
                storage_id: object::uid_to_inner(&storage.id),
                owner,
                times,
            }
        );
    }

    // Owner can remove their own counter
    public entry fun burn_counter(
        storage: &mut CounterStorage,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let Counter { owner, times } = df::remove(&mut storage.id, sender);
        assert!(sender == owner, 0); // Verify ownership
        
        // Remove from addresses list
        let (_, index) = vector::index_of(&storage.addresses, &sender);
        vector::remove(&mut storage.addresses, index);
        
        emit(
            BurnEvent {
                storage_id: object::uid_to_inner(&storage.id),
                owner,
                times,
            }
        );
    }

    // Check if counter exists for an address
    public fun counter_exists(storage: &CounterStorage, owner: address): bool {
        df::exists_(&storage.id, owner)
    }

    // Get all addresses with counters
    public entry fun get_all_addresses(storage: &CounterStorage): vector<address> {
        emit(
            ViewAddressesEvent {
                storage_id: object::uid_to_inner(&storage.id),
                addresses: storage.addresses
            }
        );
        storage.addresses
    }

    // Get counter value for an address
    public entry fun get_counter_value(storage: &CounterStorage, owner: address): u64 {
        let counter = df::borrow<address, Counter>(&storage.id, owner);
        emit(
            ViewCounterEvent {
                storage_id: object::uid_to_inner(&storage.id),
                owner,
                times: counter.times
            }
        );
        counter.times
    }

    // Increase counter function
    public entry fun increase_counter(storage: &mut CounterStorage, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(counter_exists(storage, sender), 0); // Make sure counter exists
        
        let storage_id = object::uid_to_inner(&storage.id);
        let counter = df::borrow_mut<address, Counter>(&mut storage.id, sender);
        counter.times = counter.times + 1;
        
        emit(
            CountEvent {
                storage_id,
                owner: sender,
                times: counter.times,
            }
        );
    }
}
