// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import '../core/IProfileV1.sol';

library Signature {
    using ECDSA for bytes32;

    function verifyContract(address _contract, address _profile, bytes memory _signature) internal pure returns (bool) {
        bytes memory prefix = '\x19Ethereum Signed Message:\n40';
        bytes memory encoded = abi.encodePacked(prefix, _contract, _profile);
        bytes32 digest = keccak256(encoded);

        return digest.recover(_signature) == _profile;
    }

    function verifyContract(IProfileV1 profile) internal view returns (bool) {
        return verifyContract(address(profile), profile.profileAddress(), profile.signature());
    }

    function verifyPost(
        address profile,
        uint256 nonce,
        string memory content,
        bytes memory signature
    ) internal pure returns (bool) {
        return verifyRepost(profile, nonce, profile, nonce, content, signature);
    }

    function verifyReply(
        address postProfile,
        uint256 nonce,
        address sourceProfile,
        uint256 replyNonce,
        string memory content,
        bytes memory signature
    ) internal pure returns (bool) {
        // postProfile, nonce, sourceProfile, replyNonce, keccak256(abi.encodePacked(content))
        return
            verify(
                sourceProfile,
                signature,
                postProfile,
                nonce,
                sourceProfile,
                replyNonce,
                keccak256(abi.encodePacked(content))
            );
    }

    function verifyRepost(
        address profile,
        uint256 nonce,
        address sourceProfile,
        uint256 sourceNonce,
        string memory content,
        bytes memory signature
    ) internal pure returns (bool) {
        // profile, nonce,   sourceProfile, sourceNonce, keccak256(abi.encodePacked(content))
        return
            verify(
                profile,
                signature,
                profile,
                nonce,
                sourceProfile,
                sourceNonce,
                keccak256(abi.encodePacked(content))
            );
    }

    function verify(
        address signer,
        bytes memory signature,
        address a,
        uint256 b,
        address c,
        uint256 d,
        bytes32 e
    ) private pure returns (bool) {
        bytes memory prefix = '\x19Ethereum Signed Message:\n136';
        bytes memory encoded = abi.encodePacked(prefix, a, b, c, d, e);
        bytes32 digest = keccak256(encoded);
        return digest.recover(signature) == signer;
    }
}
