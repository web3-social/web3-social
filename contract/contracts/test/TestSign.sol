// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import 'hardhat/console.sol';

contract TestSign {
    using ECDSA for bytes32;

    address public owner;
    address public profileAddress;
    bytes public signature;

    constructor(address _profileAddress) {
        owner = msg.sender;
        profileAddress = _profileAddress;
    }

    function verify(bytes memory _signature) public {
        require(msg.sender == owner);
        require(signature.length == 0);

        bytes memory prefix = '\x19Ethereum Signed Message:\n40';
        bytes memory encoded = abi.encodePacked(prefix, address(this), profileAddress);
        bytes32 digest = keccak256(encoded);

        require(digest.recover(_signature) == profileAddress);
        signature = _signature;
    }
}
