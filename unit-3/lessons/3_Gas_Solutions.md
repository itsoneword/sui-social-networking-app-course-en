# Gas Solutions

For new users, obtaining `SUI` as gas to interact with applications can be quite troublesome. On Sui, there are two solutions to solve the gas problem for users: **Sponsored Transactions** and **Batch Sending Gas**.

## Sponsored Transactions

Sui allows centralized gas providers to pay the transaction gas required by users, which is called [Sponsored Transactions](https://docs.sui.io/concepts/transactions/sponsored-transactions).

Sponsored transactions can be initiated either by the user or the sponsor.

### User-Initiated Process

1. A user initializes a `GasLessTransactionData` transaction.
2. The user sends `GasLessTransactionData` to the sponsor.
3. The sponsor validates the transaction, constructs `TransactionData` with gas fees, and then signs `TransactionData`.
4. The sponsor sends the signed `TransactionData` and the sponsor `Signature` back to the user.
5. The user verifies and then signs `TransactionData` and sends the dual-signed transaction to Sui network through a Full node or the sponsor.

### Sponsor-Initiated Process

1. A sponsor constructs a `TransactionData` object that contains the transaction details and associated gas fee data. The sponsor signs it to generate a `Signature` before sending it to a user. 
2. The user checks the transaction and signs it to generate the second `Signature` for the transaction.
3. The user submits the dual-signed transaction to a Sui Full node or sponsor to execute it.

This section of the tutorial only provides a brief introduction. In actual projects, there will be many engineering details. For example, when providing sponsored transaction services for users, if the same `Coin<SUI> gas` is used in different transactions at the same time, it will be locked for an epoch due to double-spend security issues. To avoid this problem, the `Coin<SUI> gas` is splitted into many different Objects, used by different sponsored transactions. It is also necessary to consider limiting the call frequency of individual user addresses, individual IPs, etc.

For more specifics, you can refer to Mysten's open-source [Sui Gas Pool](https://github.com/MystenLabs/sui-gas-pool) technical solution, and you can also register and use the [sponsored transaction service provided by Shinami](https://www.shinami.com/gas-station).

## Batch Sending Gas

Some application projects may choose a simpler solution. For newly registered user addresses, if a request for gas is received, gas will be distributed in batches at regular intervals, with each address receiving 0.01 SUI as gas.

The [send_gas example project](../example_projects/send_gas) provides a [sample contract](../example_projects/send_gas/sources/send_gas.move) and [sample TypeScript code](../example_projects/send_gas/scripts/send.ts) for batch forwarding of gas.

In the contract code, the batch forwarding gas function is defined as follows:
```rust
public fun send_gas(
    coin: &mut Coin<SUI>,
    value: u64,
    mut recipients: vector<address>,
    ctx: &mut TxContext
) {
    let len = vector::length(&recipients);
    let mut i = 0;

    while (i < len) {
        let recipient = vector::pop_back(&mut recipients);
        let to_sent = coin::split<SUI>(coin, value, ctx);
        transfer::public_transfer(to_sent, recipient);
        i = i + 1;
    };
}
```

In the called TypeScript program, the construction of the PTB transaction message is as follows:
```TypeScript
const tx = new Transaction();
tx.moveCall({
    package: PACKAGE_ID,
    module: "send_gas",
    function: "send_gas",
    arguments: [
        tx.gas,
        tx.pure(bcs.U64.serialize(0.01 * 1_000_000_000)),
        tx.pure(bcs.vector(bcs.Address).serialize(recipients).toBytes()),
    ],
});
```
The first parameter is tx.gas by default, which is `Coin<SUI>`.
The second parameter is value, 0.01 SUI = 0.01 * 1_000_000_000 MIST, so the input is 10_000_000.
The third parameter is the list of all recipient addresses.

Regarding the provided URLs, if you were unable to access the content of the web pages due to network issues, please be informed that the failure to parse the web pages may be due to the legitimacy of the links or network-related problems. I recommend checking the validity of the web page links and trying again if necessary. If you do not require the parsing of these links to answer your question, I will proceed to answer your question as normally.
