# Cryptography Design

This project uses the secp256k1 curve, same curve as Ethereum.

A social identity is derived from the public key, using the same algorithm as Ethereum to calculate the address from the public key.

The secret key of it is a 32-bytes of random data which can also be derived from a mnemonic phrase (as described in BIP-39).
The key generation and management is not defined in this standards.
Implementations MAY choose different design.
