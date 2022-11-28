// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/introspection/ERC165Checker.sol';
import '../core/IProfileV1.sol';
import '../bridge/IResolver.sol';
import '../util/Signature.sol';

library Compat {
    bytes4 internal constant PROFILE_V1_INTERFACE_ID = type(IProfileV1).interfaceId;
    bytes4 internal constant RESOLVER_INTERFACE_ID = type(IResolver).interfaceId;

    enum GetContractError {
        NoError,
        InvalidSignature,
        UnsupportedInterface
    }

    function _supportsProfileV1(address _address) internal view returns (bool) {
        return ERC165Checker.supportsInterface(_address, PROFILE_V1_INTERFACE_ID);
    }

    function tryGetLatestAddress(address _contractAddress) internal view returns (GetContractError, address) {
        address contractAddress = _contractAddress;
        while (contractAddress != address(0)) {
            address newAddress = IProfileV1(contractAddress).newContractAddress();
            // reach the latest contract
            if (newAddress == address(0)) {
                break;
            } else {
                if (!_supportsProfileV1(newAddress)) {
                    return (GetContractError.UnsupportedInterface, address(0));
                }
                if (!Signature.verifyContract(IProfileV1(newAddress))) {
                    return (GetContractError.InvalidSignature, address(0));
                }
                contractAddress = newAddress;
            }
        }
        return (GetContractError.NoError, contractAddress);
    }

    function getLatestAddress(address _contractAddress) internal view returns (address) {
        (GetContractError _error, address contractAddress) = tryGetLatestAddress(_contractAddress);
        if (_error == GetContractError.NoError) {
            return contractAddress;
        } else if (_error == GetContractError.InvalidSignature) {
            revert('GetContract: signature verification failed');
        } else if (_error == GetContractError.UnsupportedInterface) {
            revert('GetContract: unsupported contract address');
        }
        revert('unreachable');
    }
}
