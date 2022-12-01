# Signature

## Generation

Signature of a message is signed using `personal_sign` method of Ethereum RPC.
Implementations MUST sign the message in the same algorithm.

The process of signing a message can be described as:
```
msgHash = keccak256("\x19Ethereum Signed Message:\n" + msgLength + msg))
signature = ecSign(msgHash, privateKey, recovered = true)
```

## Verification

The verification of the signature can be done by using `ecRecover`.
Implementations MUST verify the signature in the same algorithm.

The process of signing a message can be described as:
```
msgHash := keccak256("\x19Ethereum Signed Message:\n" + msgLength + msg))
address = ecRecover(msgHash, signature)
assert(address == signer)
```