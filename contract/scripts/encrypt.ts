// web3-social using secp256k1 same as ethereum
import { randomBytes } from "node:crypto";
import { encrypt, decrypt, PrivateKey, PublicKey } from 'eciesjs';
import Web3 from "web3";
import EthCrypto from 'eth-crypto';

async function main() {
    const web3 = new Web3("http://127.0.0.1:7545");

    const profilePrivateKey = randomBytes(32).toString('hex');
    const profileAccount = web3.eth.accounts.privateKeyToAccount(profilePrivateKey);
    const profilePubkey = EthCrypto.publicKeyByPrivateKey(profilePrivateKey);
    console.log('profile address', profileAccount.address);
    console.log('profile pubkey', profilePubkey);

    const msg = web3.utils.encodePacked(
        { value: "0xffffffffffffffffffffffffffffffffffffffff", type: "address" },
        { value: profileAccount.address, type: "address" },
    )!;
    const sig = profileAccount.sign(msg);
    console.log(sig.signature);

    // method to retrive pubkey
    const recoveredPubkey = "0x" + EthCrypto.recoverPublicKey(sig.signature, sig.messageHash!);
    console.log('recovered pubkey', recoveredPubkey);

    // encrypt
    const encKey = PrivateKey.fromHex(profilePrivateKey);
    const secret = Buffer.from('THIS IS SECRET!!');
    const encrypted = encrypt(recoveredPubkey, secret);
    const decrypted = decrypt(profilePrivateKey, encrypted);
    console.log(decrypted.toString());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});