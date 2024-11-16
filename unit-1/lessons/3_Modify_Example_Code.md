# Modify Example Code

### Experimental Analysis
The results of the experiment at the end of the last lesson are as follows:

Operation | arg0 = Own Address | arg0 = 0x0
--|--|--
counter | Counting increment completed | Error reported

Operation | Count first then delete | Delete first then count
--|--|--
Result | Completed in order | Error reported when executing count, showing Counter does not exist
Analysis | After delete, the Object no longer exists and cannot be called again

## Object Ownership

Sui is a data model centered around Objects, which can be categorized into four types based on [ownership](https://move-book.com/object/ownership.html).

- **Account Owner** Owned by a single account address, only the owner can call it
- **Shared State** Shared ownership, any address can call it
- **Immutable (Frozen) State** Immutable type, can be used to record configuration parameters that will not change anymore, published smart contract packages also belong to this type
- **Object Owner** Owned by other Objects, used to construct more complex data structures, learn it later when used

### Account Owner Owned by Account Address

Use the command line to view the attributes of the Object minted by `mint`
```
sui client object 0xb0e24862cf183e276cb1c1a9c92d718a67ee759aaba00d62638d22646820cc7b
```
It is clear that there is an `owner` attribute, indicating the account address of the ownership. When called, it will be compared with the account address that initiated the request. Only when they are consistent will the function continue to be called, otherwise an error will be reported.
```
╭───────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ objectId      │  0xb0e24862cf183e276cb1c1a9c92d718a67ee759aaba00d62638d22646820cc7b                                               │
│ version       │  83977972                                                                                                         │
│ digest        │  91cHe3zzchUmxiKA1b33GzCCTaU48rcMySfk6bpY6AwK                                                                     │
│ objType       │  0xf97e49265ee7c5983ba9b10e23747b948f0b51161ebb81c5c4e76fd2aa31db0f::counter::Counter                             │
│ owner         │ ╭──────────────┬──────────────────────────────────────────────────────────────────────╮                           │
│               │ │ AddressOwner │  0x8b8c71fb95ec259a279eb8e61d52d00eb103fcd524b8fe7ff4c405c484c8a25b  │                           │
│               │ ╰──────────────┴──────────────────────────────────────────────────────────────────────╯                           │
│ prevTx        │  HZVhnXWWntcycxPfsK2Sv1ZHrdou3vnbQLgWd6X7u164                                                                     │
│ storageRebate │  1360400                                                                                                          │
│ content       │ ╭───────────────────┬───────────────────────────────────────────────────────────────────────────────────╮ │
│               │ │ dataType          │  moveObject                                                                               │ │
│               │ │ type              │  0xf97e49265ee7c5983ba9b10e23747b948f0b51161ebb81c5c4e76fd2aa31db0f::counter::Counter     │ │
│               │ │ hasPublicTransfer │  true                                                                                     │ │
│               │ │ fields            │ ╭───────┬───────────────────────────────────────────────────────────────────────────╮ │ │
│               │ │                   │ │ id    │ ╭────┬──────────────────────────────────────────────────────────────────────╮ │ │ │
│               │ │                   │ │       │ │ id │  0xb0e24862cf183e276cb1c1a9c92d718a67ee759aaba00d62638d22646820cc7b  │ │ │ │
│               │ │                   │ │       │ ╰────┴──────────────────────────────────────────────────────────────────────╯ │ │ │
│               │ │                   │ │ times │  0                                                                            │ │ │
│               │ │                   │ ╰───────┴───────────────────────────────────────────────────────────────────────────────╯ │ │
│               │ ╰───────────────────┴───────────────────────────────────────────────────────────────────────────────────────────╯ │
╰───────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### Shared State Shared Ownership
There are also many data that need to be callable by anyone in business, such as Market needing to allow different users to deposit assets for trading.
If we change the `Counter` in the previous section's code to a counter that anyone can call, we only need to change the `mint` function to:
```rust
public fun mint(ctx: &mut TxContext) {
    let counter = new(ctx);
    transfer::public_share_object(counter);
}
```

The `public_share_object` function changes the generated `counter` Object to a state of shared ownership, so that the generated counter `Counter` can be called by any account address.

### Fast Path & Consensus Execution Efficiency
Different Object ownership will affect the execution efficiency of the program.
If an Object's data is being read and written by multiple people, it needs to be sorted and locked. Shared State data with shared ownership needs to be treated in this way.
If the Object's data only belongs to an individual account, it will only be operated by the individual and does not need to be sorted and locked, which can confirm the state more quickly, also known as Fast Path.
As for Objects owned by other Objects, they are processed according to the type of the top-level Object.
Sui Move smart contracts will classify according to the type of function input parameters when executing, choosing different execution efficiencies. When designing contracts, you can choose a better solution according to the needs.

### Homework One
Rewrite the [counter](../example_projects/counter/sources/counter.move) project code to generate a shared ownership `Counter`, and then use different account addresses to call the counter.

## Event

Just like servers output execution logs, Sui blockchain also outputs the results of smart contract executions as Events for easy retrieval. However, it needs to be defined in the contract itself.

[This](../example_projects/counter_event/sources/counter_event.move) is a sample code that adds Event functionality to the original counter project [counter_event](../example_projects/counter_event/sources/counter_event.move).

Here are some key points of the modification.

1. Introduce the event module within the module.

```rust
use sui::event::emit;
```

2. Define the Event data structure.

```rust
public struct CountEvent has copy, drop {
    id: ID,
    times: u64,
}
```
This defines a data structure with `copy`, `drop` capabilities.

3. Add emit event functionality to the original functions.

```rust
public fun count(counter: &mut Counter) {
    counter.times = counter.times + 1;

    emit(
        CountEvent {
            id: object::id(counter),
            times: counter.times,
        }
    );
}
```
After adding these Event features, when executed again, you can see the Event records on the explorer.

![event](../images/explorer04.png)

### Homework Two

In the [counter_event](../example_projects/counter_event/sources/counter_event.move) sample code, add Event functionality for `mint`, `burn` respectively.

## Ability

So far, we have encountered all the Struct capabilities on Sui Move, a total of 4.

- key
- store
- copy
- drop

### key

Like traditional K-V databases, a `key` is needed to store and retrieve data in the blockchain database. Objects with `key` capability can be stored at the top level and can be held by an address or account.

The `key` here is actually `UID`, a globally unique `0x..` starting address generated when creating an Object.
When defining an Object with `key` capability, the first attribute must be `id: UID`.

```rust
use std::string::String;

public struct Object has key {
    id: UID, // required
    name: String,
}

/// Creates a new Object with a Unique ID
public fun new(name: String, ctx: &mut TxContext): Object {
    Object {
        id: object::new(ctx), // creates a new UID
        name,
    }
}
```

And `UID` is globally unique and cannot be copied `copy` and discarded `drop`. Therefore, an Object with `key` capability cannot have `copy` or `drop` capabilities.

[Reference material](https://move-book.com/storage/key-ability.html) 

### store

The `store` capability supports an Object to be stored as a child Object in other Objects.

```rust
/// This type has the `store` ability.
public struct Storable has store {}

/// Config contains a `Storable` field which must have the `store` ability.
public struct Config has key, store {
    id: UID,
    stores: Storable,
}

/// MegaConfig contains a `Config` field which has the `store` ability.
public struct MegaConfig has key {
    id: UID,
    config: Config, // there it is!
}
```

[Reference material](https://move-book.com/storage/store-ability.html) provides more basic data structures with `store` capability. 

### copy

Allows the Struct to be copyable, usually used with `drop`.

```rust
public struct Value has copy, drop {}
```

[Reference material](https://move-book.com/move-basics/copy-ability.html) provides more basic data structures with `copy` capability. 

### drop

Supports automatic discarding and destruction of data after the scope ends, recycling storage resources.
The scope, put simply, is the range of the innermost `{ ... }` brackets containing the data.

```rust
module book::drop_ability {

    /// This struct has the `drop` ability.
    public struct IgnoreMe has drop {
        a: u8,
        b: u8,
    }

    /// This struct does not have the `drop` ability.
    public struct NoDrop {}

    #[test]
    // Create an instance of the `IgnoreMe` struct and ignore it.
    // Even though we constructed the instance, we don't need to unpack it.
    fun test_ignore() {
        let no_drop = NoDrop {};
        let _ = IgnoreMe { a: 1, b: 2 }; // no need to unpack

        // The value must be unpacked for the code to compile.
        let NoDrop {} = no_drop; // OK
    }
}
```

[Reference material](https://move-book.com/move-basics/drop-ability.html) provides more basic data structures with `drop` capability. 

### Homework Three

Define a Profile NFT that can be minted and sent to any address.
The Profile data structure includes the username handle and points
```rust
public struct Profile has key {
    id: UID,
    handle: String,
    points: u64,
}
```
The holder can increase points by calling the `click` function each time. The implementation of String input refers to the example code in the [key section](#key).

## Time

[Many applications also need to obtain time information on the chain. There are two ways to obtain time on Sui](https://move-book.com/programmability/epoch-and-time.html): 

- epoch timestamp records the start time of the current `epoch`, not very accurate, can be obtained from `tx_context`, each `epoch` is about 24 hours;
- clock can obtain more accurate time, need to introduce the `sui::clock` module additionally.

The units are milliseconds ms.

### epoch timestamp

In the [example code](../example_projects/profile_epoch_time/sources/profile_epoch_time.move), the `click` function is modified to allow the `click` function to be executed only once per `epoch`. `assert!` is an assertion constraint, if the condition is not met, the program cannot be executed, and all states are returned.

```rust
public fun click(profile: &mut Profile, ctx: &TxContext) {
    let this_epoch_time = ctx.epoch_timestamp_ms();
    assert!(this_epoch_time > profile.last_time);
    profile.last_time = this_epoch_time;
    profile.points = profile.points + 1;
}
```

### clock

In the [example code](../example_projects/profile_clock/sources/profile_clock.move), it is stipulated that the time for each execution of the `click` function must be greater than 1 hour.

Introduce the clock module.
```rust
use sui::clock::Clock;
```

Define a one-hour time constant.
```rust
const ONE_HOUR_IN_MS: u64 = 60 * 60 * 1000;
```

The updated `click` function.
```rust
public fun click(profile: &mut Profile, clock: &Clock) {
    let now = clock.timestamp_ms();
    assert!(now > profile.last_time + ONE_HOUR_IN_MS);
    profile.last_time = now;
    profile.points = profile.points + 1;
}
```
