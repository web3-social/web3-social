# Terminology

## Social Identity

A social identity is an cryptographic keypair associated to represent a person or an organization.

The address of a social identity derived from the public key of a secp256k1 key using the same algorithm as Ethereum.
The address **MAY** also be called as "Profile address".

## Entities

### Profile

Profile is a contract instance owned by a social identity.

A Profile **MUST** be able to prove the ownership of the social identity by providing the signature of `contract address + profile address`.

### Resolver

A Resolver is a contract instance which is able to resolve a Profile address to a Profile contract address.

A Resolver **MUST** validate the ownership of the Profile before updating the mapping.

## Actions

### Follow

Follow is an action to follow a Profile from a Profile.

- Target Profile **MAY** decide to accept or reject the follow request.
- Target Profile **MAY** charge a fee for the follow request.
- Target Profile **MAY** return some fee in the follow response.

The action **MUST** emit an PendingFollowEvent from the target Profile if it returns a Pending.
The action **MUST** emit an NewFollowingEvent or FollowingRejectedEvent from the source Profile.
The action **MUST** emit an NewFollowerEvent from the target Profile if it accept the request.

### Unfollow

Unfollow is an action to unfollow a Profile from a Profile.

- Target Profile **SHOULD** handle the unfollow notification sent from the source Profile.
- Source Profile **MUST** ignore any error occurs when sending unfollow notification.

The action **MUST** emit an UnfollowEvent from the source Profile.

### Post

Post is an action of publishing a message from a Profile.

The Profile **MUST** provide valid signature in the PostEvent.

The action **MUST** emit an PostEvent.

### Repost

Repost is an action of publishing repost of another post from a Profile.

The Profile **MUST** provide valid signature in the PostEvent.

The action **MUST** emit an PostEvent.

### Reply

Reply is an action of publishing a reply to another post from a Profile.

- The Profile of the original post **MAY** reject the reply request by failing the action.
- The Profile of the original post **MAY** increase the gas cost of the reply request.

The action **MUST** emit an ReplyEvent in the Profile of the original post.