// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "../core/IProfileV1.sol";
import "../bridge/IResolver.sol";

library Compat {
    using ECDSA for bytes32;

    bytes4 internal constant PROFILE_V1_INTERFACE_ID = type(IProfileV1).interfaceId;
    bytes4 internal constant RESOLVER_INTERFACE_ID = type(IResolver).interfaceId;

    function _supportsProfileV1(address _address) internal view returns (bool) {
        return ERC165Checker.supportsInterface(_address, PROFILE_V1_INTERFACE_ID);
    }

    function verify(address _contract, address _profile, bytes memory _signature) internal pure returns (bool) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n40";
        bytes memory encoded = abi.encodePacked(prefix, _contract, _profile);
        bytes32 digest = keccak256(encoded);
        
        return digest.recover(_signature) == _profile;
    }
}