# Registration Binding

When a new user registers to use the product, a SoulBound Token (SBT), which can be understood as a non-transferable NFT, can be sent to their on-chain address to bind the registration information.

## Admin Privileges AdminCap
Compared to the permissionless `mint` function in the [profile_clock example code](../../unit-1/example_projects/profile_clock/) from the first unit, a more common implementation is to use administrative privileges to register users after receiving registration information.

The [sign_up example code](../example_projects/sign_up/sources/sign_up.move) changes the original permissionless registration method to one that requires administrative privileges.

First, an `AdminCap` administrative privilege Object is defined.
```rust
public struct AdminCap has key, store {
    id: UID,
}
```

The functionality to generate `AdminCap` is placed within the `init` function, which is a function that is automatically executed only once when the contract is deployed.

```rust
fun init(ctx: &mut TxContext) {
    let admin = AdminCap {
        id: object::new(ctx),
    };
    transfer::public_transfer(admin, ctx.sender());
}
```

This function generates `AdminCap` and sends it to the address of the user who deployed the contract.

In the original `mint` function, `&AdminCap` is added as an input parameter, which is not actually used, so the parameter name `_admin` is prefixed with an underscore. When calling the `mint` function, the Object ID of `&AdminCap` must be input; if it is not called from the address with `AdminCap`, an error will occur. This restricts the `mint` function to be callable only by administrators.
```rust
public fun mint(_admin: &AdminCap, handle: String, recipient: address, ctx: &mut TxContext) {
    let profile = new(handle, ctx);
    transfer::transfer(profile, recipient);
}
```

## NFT vs SBT

In this new example code, a new question arises: why are `transfer::transfer` and `transfer::public_transfer` used sometimes to transfer assets, and what is the difference between them?

In Sui, Objects can be divided into Objects that can be freely transferred and traded, such as NFTs and Coins, and Objects that cannot be freely transferred and traded, which are suitable for SBTs.

In the example code, `AdminCap` includes both `key` and `store` capabilities when defined, belonging to Objects that can be freely transferred.
```rust
public struct AdminCap has key, store {
    id: UID,
}
```
While `Profile` only has the `key` capability, belonging to Objects that cannot be freely transferred.
```rust
public struct Profile has key {
    id: UID,
    handle: String,
    points: u64,
    last_time: u64,
}
```

For Objects that can be freely transferred, the `public_transfer`, `public_freeze_object`, `public_share_object` methods of the [`transfer` module](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/transfer.move) can be used in [PTB](../../unit-2/lessons/2_调用合约.md#可编程交易块-ptbprogrammable-transaction-blocks) or any other contract to handle the Object, which can be forwarded to other accounts, becoming shared or frozen.

However, for Objects that cannot be freely transferred, only the `transfer`, `freeze_object`, `share_object` methods of the [`transfer` module](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/transfer.move) can be used **within** the module where the Object is defined to handle it.

## Table and Deduplication

When registering a user account, it is necessary to avoid duplicate registrations for the same account or address. This can be achieved using the `Table` data structure for deduplication.
The [example program](../example_projects/sign_up_table/sources/sign_up_table.move) defines an additional data structure specifically for recording registered account information on top of the original code.
```rust
public struct HandleRecord has key {
    id: UID,
    record: Table<String, bool>,
}
```
When registering a new account, the `handle` information is used as the `key` for registration.
```rust
public fun mint(
    _admin: &AdminCap, 
    handle_record: &mut HandleRecord, 
    handle: String, 
    recipient: address, 
    ctx: &mut TxContext
) {
    table::add<String, bool>(&mut handle_record.record, handle, true);
    let profile = new(handle, ctx);
    transfer::transfer(profile, recipient);
}
```
Here, `table::add<String, bool>(&mut handle_record.record, handle, true);` will fail to add and roll back the program execution if there is a duplicate `handle`; the `true` boolean value is just a placeholder and has no actual meaning.

### Homework

When checking for duplicate registrations, not only should `handle` be deduplicated, but also `address`. Based on the example code in this section, add an additional data structure for checking `address` duplicates. Prohibit registered `handle` and `address` from registering again.

## Table, TableVec, VecMap, VecSet, vector

If it's just for deduplication, according to conventional programming habits, data structures like sets should be used, and Sui has defined similar data structures, such as [`VecMap`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/vec_map.move), [`VecSet`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/vec_set.move). So why did we choose the [`Table`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/table.move) data structure for implementation?

On Sui, any Object has a data storage limit. Both `VecMap` and `VecSet` are built based on the `vector` data structure and belong to a single Object. When too much data is stored, it will no longer be callable.

However, `Table` and `TableVec` create new data as individual Objects when adding new data, and then bind the ownership of the newly added data to `Table` or `TableVec` using the [dynamic_field](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/dynamic_field.move) dynamic attribute. This supports these two data structures to add data without limits.

### Homework

Read the source code of these data structures:
- [VecMap](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/vec_map.move) 
- [VecSet](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/vec_set.move) 
- [vector](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/move-stdlib/sources/vector.move) 
- [Table](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/table.move) 
- [TableVec](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/table_vec.move) 

If our application has a referral registration feature and needs to record the referral registration relationship between users on the blockchain, try to choose the most suitable one from these data structures to build, and write the Sui Move contract code.
