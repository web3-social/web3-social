// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IResolver is IERC165 {

    /**
     * @dev emit when a contract is verified with its profile address
     */
    event VerifiedEvent(address indexed profileAddress, address indexed contractAddress);
    /**
     * @dev emit when a contract is verified and record is updated
     */
    event UpdateEvent(address indexed profileAddress, address indexed latestAddress);

    /**
     * @dev resolve a profile address to latest contract address
     * @return address 0x0 if not exist
     */
    function resolve(address profileAddress) external view returns (address);

    /**
     * @dev called by a Profile contract to update record
     */
    function updateRecord() external;

    /**
     * @dev manually called to update record
     */
    function manuallyUpdate(address latestAddress) external;
}