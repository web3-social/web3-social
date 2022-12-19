# Introduction

> The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.

This project is aimed for web3 social protocol standard.

## Q&A

1. Why build social network with web3 and Ethereum?

    Building a social network with web3 and Ethereum can provide a number of benefits compared to building a traditional, centralized social network. One of the main benefits is that it can be decentralized, which means that it is not controlled by any single entity and can operate on a global, peer-to-peer basis. This can make it more resistant to censorship and other forms of interference, as well as making it more secure and resilient.

    In addition, using Ethereum and web3 allows the social network to take advantage of the **robust infrastructure and security features** that are built into the Ethereum platform. This can help to address issues such as **synchronization and spam**, as these are issues that have already been addressed by the Ethereum team and community.

2. Do users have to have a wallet to use this protocol?

    Yes, users will **typically** need a wallet to interact with a social network that is built using web3 and Ethereum. This is because transactions on the Ethereum network, including those related to the social network, require users to have an Ethereum wallet in order to sign and send transactions. 
    
    However, it is possible for users to **delegate their operations to a service provider**, who can act on their behalf and potentially use other payment methods to cover the costs of transactions. This can make it easier for users who are not familiar with Ethereum or who do not want to manage their own wallet to still use the social network.

3. What if the service provider will censor the content?

    If a service provider begins to censor content, users have several options for responding. It's easy to migrate their identity contract to a different service provider as the identity contract is typically designed to be upgradable and can be easily migrate from one to another.

    Another option is for users to interact with the contract directly, rather than going through a service provider. This can give them more control over their content and can help to prevent censorship, as the **contract itself is always controlled by yourself**.

    It is also possible to have a **SaaS platform** that offers on-click deployment of service providers, allowing users to quickly and easily set up and run their own provider that they trust and will not censor their content.

4. On-chain storage is expensive, where do users' data store?

    **Only** metadata is stored in contract storage. The actual content of the data, such as a text post or a photo, is emitted as an event on the blockchain, and is not stored directly on the chain.

    To further save on storage costs, the content of the data is often stored using a URL-like format, such as "ipfs://", which points to the location of the data on a decentralized storage platform such as InterPlanetary File System (IPFS).