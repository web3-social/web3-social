// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/introspection/ERC165.sol';
import '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import './IResolver.sol';
import '../core/IProfileV1.sol';
import '../util/Compat.sol';
import '../util/Signature.sol';

contract Resolver is IResolver, ERC165 {
    mapping(address => address) _records;

    modifier onlyFromProfile() {
        require(Compat._supportsProfileV1(msg.sender));
        _;
    }

    /**
     * @dev resolve a profile address to latest contract address
     * @return latestAddress 0x0 if not exist
     */
    function resolve(address profileAddress) external returns (address latestAddress) {
        latestAddress = _records[profileAddress];
        // update if exist
        if (latestAddress != address(0)) {
            latestAddress = Compat.getLatestAddress(latestAddress);
            _records[profileAddress] = latestAddress;
            emit UpdateEvent(profileAddress, latestAddress);
        }
    }

    /**
     * @dev manually called to update record
     */
    function update(address latestAddress) external {
        address profileAddress = _verifyAll(latestAddress);
        _records[profileAddress] = latestAddress;
        emit UpdateEvent(profileAddress, latestAddress);
    }

    function _verifyAll(address latestAddress) private view returns (address profileAddress) {
        require(Compat._supportsProfileV1(latestAddress), 'unsupported contract address');
        require(Signature.verify(IProfileV1(latestAddress)), 'signature verification failed');
        profileAddress = IProfileV1(latestAddress).profileAddress();

        // recursive check if there is a history record
        address contractAddress = _records[profileAddress];
        if (contractAddress != address(0)) {
            contractAddress = Compat.getLatestAddress(contractAddress);
            require(contractAddress == latestAddress, 'provided address is not latest');
        }
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        return interfaceId == Compat.RESOLVER_INTERFACE_ID || super.supportsInterface(interfaceId);
    }
}
