# Signature
In the application, a lot of point data is uploaded to the chain, such as points for playing games, watching videos and ads, and points for clicks and interactions. If these points are simply input as function input parameters in the smart contract, they can be easily tampered with by hackers.

To control and only allow the upload of real data, the data also needs to be verified on the blockchain. The general process is:
1. The project generates a public and private key pair, and stores the public key in the smart contract.
2. When a user initiates a transaction request that requires a private key signature, the server queries the data, constructs a signature to be verified, and builds the transaction request with the input parameters and the signature to be verified, sending it back to the user.
3. The user receives the transaction information containing the signature to be verified, confirms it is correct, authorizes the signing of the transaction, and sends the transaction and the user's signature for the transaction to the application.
4. The application sends the user's transaction and the signature for the transaction to the full node, calling the smart contract function.
5. The smart contract uses the public key to verify the data and the signature. If it is legal, it updates the data.

Since the private key is confidential and only in the hands of the project team, it cannot be changed by hacker groups.

## Generating Public and Private Key Pairs

In [Unit 2, example code for randomly generating public and private key pairs has already been provided](../../unit-2/example_projects/generate.ts). For the convenience of teaching demonstrations, this unit will import the same private key.  
** In specific projects, please generate independent and confidential private keys, and do not use the same private key as this tutorial!!!

```typescript
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { fromHex, toHex } from "@mysten/sui/utils";

const secret_key = "9bf49a6a0755f953811fce125f2683d50429c3bb49e074147e0089a52eae155f"
const keypair = Ed25519Keypair.fromSecretKey(fromHex(secret_key));
console.log(keypair);

const address = keypair.toSuiAddress();
console.log(address);
```
Here, `fromHex` is to convert the hexadecimal private key to the `Uint8Array` format.

In this example program, the private key used is `9bf49a6a0755f953811fce125f2683d50429c3bb49e074147e0089a52eae155f`, and the public key is `b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a49200`.

Converted to `Uint8Array` format respectively are
Private key `[ 155, 244, 154, 106, 7, 85, 249, 83, 129, 31, 206, 18, 95, 38, 131, 213, 4, 41, 195, 187, 73, 224, 116, 20, 126, 0, 137, 165, 46, 174, 21, 95 ]`
Public key `[ 185, 198, 238, 22, 48, 239, 62, 113, 17, 68, 166, 72, 219, 6, 187, 178, 40, 79, 114, 116, 207, 190, 229, 63, 252, 238, 80, 60, 193, 164, 146, 0 ]`

There are many encryption algorithms to choose from in addition to `ed25519`, and the [official documentation](https://docs.sui.io/guides/developer/cryptography/signing) provides more examples, which can be chosen as needed.

## Signing Data with a Private Key

The `Keypair` data structure comes with a method for signing messages, and the data structure passed in is in `Uint8Array` format.

```TypeScript
async sign(data: Uint8Array) {
	return nacl.sign.detached(data, this.keypair.secretKey);
}
```

The [example program](../example_projects/crypto/sign.ts) demonstrates how to sign messages using the imported private key.
```TypeScript
const msg = new Uint8Array([5, 6, 7]);
const signature = await keypair.sign(msg);
console.log(signature);
```

### Assignment

Generate a random `Keypair` using the TypeScript SDK, and record one pair of public and private keys. Import the private key locally to get `Keypair`, and then sign any message.
