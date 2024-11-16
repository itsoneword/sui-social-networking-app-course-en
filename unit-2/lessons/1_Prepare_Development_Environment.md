# Prepare Development Environment

## Installation and Initialization

The TypeScript SDK is an SDK developed by Sui officially to facilitate interaction with smart contracts and is a necessary feature to be familiar with when developing dapp applications.

This unit's teaching will use `bun` as the running environment, which can be installed [referencing the bun documentation](https://bun.sh/docs/installation).

After installation, if it is a new project directory, you need to execute the command line.
Initialize the project folder
```bash
bun init
```
Add SDK dependencies
```bash
bun add @mysten/sui
```

After execution, you can get the file structure in the [example project](../example_projects/).

## Account

### Randomly Generate Account

You can [refer to the generate code](../example_projects/generate.ts) to randomly generate an account.
Randomly generated accounts have no gas, and you can import the wallet app to receive gas.

### Import Existing Account

If you have had an account before, we can import the mnemonic or private key from the local. Here is a [sample code for importing mnemonics](../example_projects/import.ts).

* Real production code will not write mnemonics or private keys in the code but will save them as environment variables in a `.env` file to avoid accidental upload to the outside.

* At this point, the import command becomes `const mnemonics: string = process.env.MNEMONICS!;`

### Save Account

If you want to save mnemonics or private keys, saving them in plain text is very dangerous. You can refer to [MetaMask's scheme to encrypt and save](https://github.com/MetaMask/browser-passworder).

### Okx-Connect

If you are developing a Telegram app, Okx also provides a [technical solution for Okx-Connect](https://www.npmjs.com/package/@okxconnect/sui-provider?activeTab=readme), which can awaken the local Okx wallet from the app and authorize transaction signing. For many users, they are not confident in storing private keys/mnemonics in the Telegram app and dare not place too many assets. Okx-Connect can solve their trust issues.
