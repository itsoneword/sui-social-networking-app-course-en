# Publish Example Code

Quickly understand Sui Move development with a minimal counter example code.

### Setting Up the Environment

Refer to the [guide](https://docs.sui.io/guides/developer/getting-started) to install the local development environment for Sui.
- [Switch to connect to the TestNet or DevNet](https://docs.sui.io/guides/developer/getting-started/connect), the default command is `sui client switch --env testnet`.
- [Create an account](https://docs.sui.io/guides/developer/getting-started/get-address), the default command is `sui client new-address ed25519`.
- Use `sui client faucet` to obtain gas.

If the above steps are completed, use `sui client gas` to see the gas balance on your account. Gas is required when publishing contracts and interacting with them on the blockchain. The gas used on the Sui network is called `SUI`, and the smallest unit is `MIST`, `1 SUI = 1,000,000,000 MIST`.

There are many command line commands, the most commonly used are `sui move` for compiling and testing code, and `sui client` for calling the local client to publish, call, and upgrade contracts. Browse through them briefly, and when in doubt, check with `sui move --help` and `sui client --help`.

### Deploying Contracts

In the example code, there is a minimal [counter project](../example_projects/counter/).
Enter the directory of the counter project and compile the code with the command.

```
sui move build --skip-fetch-latest-git-deps
```
You can see that the compilation is successful, and a `/build` directory and a `Move.lock` file are generated.

*Compilation is a very important feature. Both `Move` and `Rust` have compilers that drive development. In actual development, you can let the compiler check after each function is written to find problems in the code.  
*The actual development process is [compile, test](https://docs.sui.io/guides/developer/first-app/build-test), publish on the testnet, and publish on the mainnet. This tutorial is concise and selective in content. When testing, [using debug output values](https://docs.sui.io/guides/developer/first-app/debug) is also a common technique.  

Continue to publish the contract code to the testnet.
```
sui client publish --gas-budget 800000000 --skip-dependency-verification --skip-fetch-latest-git-deps
```

After successful publication, the publication execution result will be returned. Good development practice is to copy the [publication result](../example_projects/counter/publish-record) and save it locally. It will contain a lot of information related to contract calls.

In the [publication result](../example_projects/counter/publish-record), you can find the published contract address `PackageID: 0xf97e49265ee7c5983ba9b10e23747b948f0b51161ebb81c5c4e76fd2aa31db0f`.

Use the [blockchain explorer to open the contract address](https://explorer.polymedia.app/object/0xf97e49265ee7c5983ba9b10e23747b948f0b51161ebb81c5c4e76fd2aa31db0f?network=testnet), where you can execute the contract code.

![explorer](../images/explorer01.png)

Commonly used Sui explorers include:
- [SuiVision](https://suivision.xyz/)
- [SuiScan](https://suiscan.xyz/)
- [PolyMedia](https://explorer.polymedia.app/)

### Homework
Deploy the Sui development environment on your computer, download the [counter project code](../example_projects/counter/), publish the contract on the testnet with your own account, record and save the publication result locally, and open the contract address on the explorer.
