// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import '../core/IProfileV1.sol';

library Signature {
    using ECDSA for bytes32;

    function verify(address _contract, address _profile, bytes memory _signature) internal pure returns (bool) {
        bytes memory prefix = '\x19Ethereum Signed Message:\n40';
        bytes memory encoded = abi.encodePacked(prefix, _contract, _profile);
        bytes32 digest = keccak256(encoded);

        return digest.recover(_signature) == _profile;
    }

    function verify(IProfileV1 profile) internal view returns (bool) {
        return verify(address(profile), profile.profileAddress(), profile.signature());
    }
}
