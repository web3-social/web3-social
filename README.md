# web3 social

This project is aimed for web3 social protocol standard.

## Design

`Profile` is a social identity instance that anyone can deploy for themself.

Interacting between people is mapped to interacting of `Profile` contracts.

To seperate the wallet and social identity.
Each social identity is represented by an address which can be different to the wallet address.
Thus, you can recover your `Profile` instance as long as you keep the identity secrets.

Example:
- Wallet Address: `0xd6e09Fa89AcCD3c2E22A57545764b8023Ff56d16`
- Profile Address (social identity): `0x62E09eA82347a12a1466D7716EbB712823297a0F`
- Contract Address (Profile instance): `0xA933F04755872A62503f3168C41596922c840095`

Others can verify the signature via `function signature() returns (bytes memory)` to ensure the contract is owned by a social identity.

`Resolver` is like a registry. Anyone can link their social identity to a contract.
Using the `Resolver` you can lookup the latest contract of a social identity.
Thus, yes, you can upgrade the `Profile` contract.

Before the `Resolver` updates records,
it will verify the contract and recursive verify the chain if you made several `Profile` ugrades before updating the `Resolver` records.

Example: Contract A (current record) -> Contract B -> Contract C (current used)