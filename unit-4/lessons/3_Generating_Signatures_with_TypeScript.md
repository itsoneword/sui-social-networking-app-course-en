# Generating Signatures with TypeScript

In the previous section, we implemented a [smart contract that can verify signature](../example_projects/verify_profile/sources/verify_profile.move), and for the convenience of learning and testing, it was deployed to the [test network](https://explorer.polymedia.app/object/0xeae0ae9f148538131e4022fb4e5ec72336a61c10601d26a1957bb02fb7d3da83?network=testnet).

In this section, we will explore how to use the TypeScript SDK to construct signatures.

## Preparation Work

1. Use the [mint.ts](../example_projects/verify_profile/scripts/mint.ts) example code to mint a `Profile` SBT Object.
2. Use the [get.ts](../example_projects/verify_profile/scripts/get.ts) example code to query the `Profile` SBT Object's `handle, points, last_time` and other attribute information.

## Building a Signature

In the [sign.ts example code](../example_projects/verify_profile/scripts/sign.ts), a function `signMessage` is provided for building a signature for the contract's `add_points` function.

```TypeScript
export const signMessage = async(id: string, add_points: number, last_time: number): Promise<Uint8Array> => {
    const profile_data = bcs.struct('Profile', {
        id: bcs.Address,
        add_points: bcs.u64(),
        last_time: bcs.u64(),
    });
    const profile_bytedata = profile_data.serialize({ id: id, add_points: add_points, last_time: last_time }).toBytes(); // Bytes
    const hash = keccak256(profile_bytedata); // Hex
    const hash_bytes = fromHex(hash); // Bytes
    const signature_bytes = await keypair.sign(hash_bytes); // Bytes
    return signature_bytes;
}
```

It includes the following steps:

### BCS Serialization

[BCS](https://github.com/MystenLabs/sui/blob/main/sdk/bcs/src/bcs.ts) is a serialization format standard that converts data structures into binary encoding.

First, define the serialization data structure according to the `Profile` format in the smart contract.
```TypeScript
const profile_data = bcs.struct('Profile', {
    id: bcs.Address,
    add_points: bcs.u64(),
    last_time: bcs.u64(),
});
```
Serialize the input data of the function.
```TypeScript
const profile_bytedata = profile_data.serialize({ id: id, add_points: add_points, last_time: last_time }).toBytes();
```

### Hash Calculation

Put the BCS serialization result `profile_bytedata` into the `keccak256` algorithm to calculate the hash value. The result is in hexadecimal, which is then converted to binary.
```TypeScript
const hash = keccak256(profile_bytedata);
const hash_bytes = fromHex(hash);
```

### Signature Generation

Finally, sign the binary data.
```TypeScript
const signature_bytes = await keypair.sign(hash_bytes);
```

## Building a Transaction

[add_points.ts](../example_projects/verify_profile/scripts/add_points.ts) demonstrates example code for calling the signature function and then building a transaction.

```TypeScript
const sign_bytedata = await signMessage(profile_id, add_points, profile_last_time);

const tx = new Transaction();
tx.moveCall({
    package: PACKAGE,
    module: "profile",
    function: "add_points",
    arguments: [
        tx.object(profile_id),
        tx.pure(bcs.u64().serialize(add_points).toBytes()),
        tx.pure(bcs.vector(bcs.u8()).serialize(sign_bytedata).toBytes()),
        tx.object("0x6"),
    ],
});
tx.setSender(address);
```

### Assignment

Implement the TypeScript code for building signatures and transaction information for the `edit_handle` function from the previous section's assignment.
