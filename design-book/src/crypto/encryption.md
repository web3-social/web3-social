# Encryption

## Public Key Retrieval

The public key of a social identity can be retrieved by using similar like `ecRecover` with the signature of a message.
`ecRecover` runs keccak256 on the public key to calculate the address.
Implementations MAY use library like `eth-crypto` to recover the public key from signature.

## Encryption Scheme

The encryption scheme is chosen to be ECIES on secp256k1.
Based on [ecies.org](https://ecies.org/) implementation, the symmetric encryption algorithm is AES-256-GCM.
