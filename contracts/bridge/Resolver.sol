// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "./IResolver.sol";
import "../core/IProfileV1.sol";
import "../util/Compat.sol";

contract Resolver is IResolver, ERC165 {

    mapping(address => address) _records;

    modifier onlyFromProfile() {
        require(Compat._supportsProfileV1(msg.sender));
        _;
    }

    /**
     * @dev resolve a profile address to latest contract address
     * @return address 0x0 if not exist
     */
    function resolve(address profileAddress) external view returns (address) {
        return _records[profileAddress];
    }

    /**
     * @dev called by a Profile contract to update record
     */
    function updateRecord() external onlyFromProfile {
        address profileAddress = _verifyAll(msg.sender);
        _records[profileAddress] = msg.sender;
        emit UpdateEvent(profileAddress, msg.sender);
    }

    /**
     * @dev manually called to update record
     */
    function manuallyUpdate(address latestAddress) external {
        address profileAddress =  _verifyAll(latestAddress);
        _records[profileAddress] = latestAddress;
        emit UpdateEvent(profileAddress, latestAddress);
    }

    function _verifyAll(address latestAddress) private returns (address profileAddress) {
        _verifySingle(latestAddress);
        profileAddress = IProfileV1(latestAddress).profileAddress();

        // recursive check contractAddress if history records exists
        address contractAddress = _records[profileAddress];
        while (contractAddress != address(0)) {
            address newAddress = IProfileV1(contractAddress).newContractAddress();
            // reach the latest contract
            if (newAddress == address(0)) {
                break;
            } else {
                _verifySingle(newAddress);
                contractAddress = newAddress;
            }
        }

        require(contractAddress == latestAddress, "provided address is not latest");
    }

    // should we cache the result?
    function _verifySingle(address contractAddress) private returns (address profileAddress) {
        require(Compat._supportsProfileV1(contractAddress), "unsupported contract address");

        IProfileV1 profile = IProfileV1(contractAddress);
        profileAddress = profile.profileAddress();
        bool result = Compat.verify(contractAddress, profileAddress, profile.signature());
        require(result, "signature verification failed");
        emit VerifiedEvent(profileAddress, contractAddress);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        return interfaceId == Compat.RESOLVER_INTERFACE_ID || super.supportsInterface(interfaceId);
    }
}