# Call Contracts

When calling contracts, the most commonly used feature is `sui client`. You can first briefly [browse the source code](https://github.com/MystenLabs/sui/blob/main/sdk/typescript/src/client/client.ts). This section will go through the commonly used features.

Let's first publish the [example code](../../unit-1/example_projects/profile_clock/sources/profile_clock.move) from the last lesson to the testnet. For the convenience of learning, a version has been published directly here [published version](https://explorer.polymedia.app/object/0xf88ed6fdffa373a09a1a54fbad1ac4730219142f7fa798bdcf632d5f159e4a18?network=testnet) for everyone to call. The testnet package ID is `0xf88ed6fdffa373a09a1a54fbad1ac4730219142f7fa798bdcf632d5f159e4a18`.

## Sign and Execute Transaction `signAndExecuteTransaction`

First, navigate to the [example_project folder](../example_projects/), and then execute the `execute.ts` program.
```bash
bun run execute.ts
```
You can see that the execution result returns a hash code. [Copy this hash code to the blockchain browser](https://explorer.polymedia.app/txblock/EajmE9pSVJvhD6XL4atJrjCgYTEfzMQSj91ArzD2Ea4Y?network=testnet) to see the execution record.

In this simplest `execute.ts` example program.

```ts
const client = new SuiClient({
    url: getFullnodeUrl("testnet"),
});
```

This initializes a Sui client within the program and specifies that the network is on testnet.

```ts
const tx = new Transaction();
tx.moveCall({
    package: PACKAGE,
    module: "profile_clock",
    function: "mint",
    arguments: [
        tx.pure(bcs.string().serialize("Example").toBytes()),
    ],
});
```
Initializes a transaction and declares the transaction content, which is to call the `mint` function of the `profile_clock` module in `PACKAGE`.
Comparing with the original contract code, there are two input parameters `handle: String, ctx: &mut TxContext`, where `ctx` can be omitted.
The input of the `String` variable needs to be encoded using the `bcs` encoding method. Remember the common input formats.

```ts
const result = await client.signAndExecuteTransaction({ signer: keypair, transaction: tx });
console.log(result);
```
This step is crucial as it signs the transaction with the private key and executes it. Finally, it prints the execution result.

## Query Objects Owned by Address getOwnedObjects

When calling the `click` function of the [contract](../../unit-1/example_projects/profile_clock/sources/profile_clock.move), you need to input the address of the `Profile` Object owned by the user and the time `Clock` as parameters.

`getOwnedObjects` can query all Objects owned by a certain address.
```ts
const object_list = await client.getOwnedObjects({owner: address});
```
How to fill in the input parameters can be viewed in the source code.

Here, you only need to find the information of the `Profile` Object under the current address, and you can additionally input filter information. And return the ID of the first Object that meets the conditions found, saved as `profile_id`.

```ts
const struct_type = "0xf88ed6fdffa373a09a1a54fbad1ac4730219142f7fa798bdcf632d5f159e4a18::profile_clock::Profile";
const object_list = await client.getOwnedObjects({ owner: address, filter: { StructType: struct_type } });
const profile_id = object_list.data[0].data!.objectId;
```
Here, `StructType` is a string composed of the format `package_id::module::struct`.

With this information, you can call the `click` function.
In the `click` function, the second parameter that needs to be input is `Clock`, which is a system-defined shared Object with ID `0x6`.
```ts
const PACKAGE: string = '0xf88ed6fdffa373a09a1a54fbad1ac4730219142f7fa798bdcf632d5f159e4a18';
const tx = new Transaction();
tx.moveCall({
    package: PACKAGE,
    module: "profile_clock",
    function: "click",
    arguments: [
        tx.object(profile_id),
        tx.object("0x6"),
    ],
});
```

## Programmable Transaction Blocks (PTB)
A great feature of Sui is that you can use programmable transaction blocks to combine many different transaction requests, even different functions from different packages. This makes building applications more flexible and free.

In the [ptb example code](../example_projects/ptb.ts), three transactions are assembled in the programmable transaction block. They are creating a `Profile` Object, using this `Profile` Object to execute the `click` function once, and then destroying the `Profile` Object.

```ts
const tx = new Transaction();
const [profile] = tx.moveCall({
    package: PACKAGE,
    module: "profile_clock",
    function: "new",
    arguments: [
        tx.pure(bcs.string().serialize("Example").toBytes()),
    ],
});
tx.moveCall({
    package: PACKAGE,
    module: "profile_clock",
    function: "click",
    arguments: [
        tx.object(profile),
        tx.object("0x6"),
    ],
});
tx.moveCall({
    package: PACKAGE,
    module: "profile_clock",
    function: "burn",
    arguments: [
        tx.object(profile),
    ],
});
```

## Simulate Transaction `dryRunTransactionBlock`

Before signing a transaction with a wallet, you can preview the execution result of the transaction. This uses Sui's simulation transaction feature.

The [dryrun example program](../example_projects/dryrun.ts) demonstrates how to use the simulation transaction feature.

```ts
tx.setSender(address);
const dataSentToFullnode = await tx.build({ client: client });
const result = await client.dryRunTransactionBlock({
    transactionBlock: dataSentToFullnode,
});
```
This simulation transaction execution will fail. Because the `points` function executed in this code requires input `&Profile`, but the ownership of this `Profile` Object is not in the current address.

## View Function `devInspectTransactionBlock`

The `devInspect` function can also view the execution effect of the function, which is similar to the `view` function of `EVM`, and does not need to pay attention to the issue of Object ownership.

The [devinspect example program](../example_projects/devinspect.ts) demonstrates how to use `devInspectTransactionBlock` to execute read functions written in the smart contract without consuming gas.

```ts
const res = await client.devInspectTransactionBlock({
    sender: normalizeSuiAddress(address),
    transactionBlock: tx,
});
console.log(res?.results?.[0]?.returnValues?.[0]?.[0]);
```

## Query Object Information `getObject`

The use of `devInspect` requires writing read functions in the contract in advance. If not, you can actually directly use `getObject` to query the data of the Object on the chain.

The [getobject example program](../example_projects/getobject.ts) provides a method for directly querying the attributes of an Object based on the Object ID.

### Assignment
Republish the contract, and then use the client functions mentioned in this section to write a TypeScript script for calling functions and reading data.
