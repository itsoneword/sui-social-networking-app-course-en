# On-Chain Signatures Verification

The [verify_profile example program](../example_projects/verify_profile/sources/verify_profile.move) builds upon the [profile_clock example program](../../unit-1/example_projects/profile_clock/sources/profile_clock.move) from the first unit, adding an `add_points` function that requires signature verification.

## Import Dependency

At the beginning of the smart contract module, import the dependency module.

```Rust
use sui::{
    clock::Clock,
    bcs,
    hash,
    ed25519
};
```

## Define Data Structures

```Rust
const PK: vector<u8> = vector[185, 198, 238, 22, 48, 
    239, 62, 113, 17, 68, 166, 72, 219, 6, 187, 178, 
    40, 79, 114, 116, 207, 190, 229, 63, 252, 238, 80, 
    60, 193, 164, 146, 0];
```
Define the constant `PK` to record the public key binary data.

```Rust
public struct ProfileData has drop {
    id: ID,
    add_points: u64,
    last_time: u64,
}
```

The `ProfileData` data structure contains the necessary information for verification, including the points to be added `add_points`, the Object ID of each `Profile`, and the last update time `last_time`. Adding this information makes the signature unique and non-reusable.  
The ability of the `ProfileData` data structure is `drop`, which allows it to be automatically destroyed after the scope ends.

## Function Implementation

```Rust
public fun add_points(
    profile: &mut Profile, 
    add_points: u64, 
    sig: vector<u8>,
    clock: &Clock
) {
    let profile_data = ProfileData {
        id: object::id(profile),
        add_points,
        last_time: profile.last_time,
    };
    let byte_data = bcs::to_bytes(&profile_data);
    let hash_data = hash::keccak256(&byte_data);
    let pk = PK;
    let verify = ed25519::ed25519_verify(&sig, &pk, &hash_data);
    assert!(verify == true);

    profile.points = profile.points + add_points;
    profile.last_time = clock.timestamp_ms();
}
```

In the function, first, construct the data to be verified `ProfileData`.
```Rust
let profile_data = ProfileData {
    id: object::id(profile),
    add_points,
    last_time: profile.last_time,
};
```

Convert `ProfileData` to binary and then calculate the hash value.
```Rust
let byte_data = bcs::to_bytes(&profile_data);
let hash_data = hash::keccak256(&byte_data);
```
Actually, the binary data can already be used for signature verification, but taking the hash value will make it fixed-length data, improving the efficiency of subsequent cryptographic algorithms. If `ProfileData` also contains variable-length string data, taking the hash value is very helpful, which is used here only for demonstration purposes.

Copy the public key data `pk`, then verify the incoming signature data `sig` and the previously calculated hash value `hash_data`.
```Rust
let pk = PK;
let verify = ed25519::ed25519_verify(&sig, &pk, &hash_data);
assert!(verify == true);
```

Finally, add the points and then update the `last_time` attribute of `Profile`.
```Rust
profile.points = profile.points + add_points;
profile.last_time = clock.timestamp_ms();
```

### Assignment
Modify the [example code of this section](../example_projects/verify_profile/sources/verify_profile.move) to add an `edit_handle` function, which allows editing the `handle` attribute of `Profile` after verifying the signature information.
