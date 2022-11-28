// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/introspection/IERC165.sol';

interface IResolver is IERC165 {
    /**
     * @dev emit when a contract is verified and record is updated
     */
    event UpdateEvent(address indexed profileAddress, address indexed latestAddress);

    /**
     * @dev resolve a profile address to latest contract address
     * @return latestAddress 0x0 if not exist
     */
    function resolve(address profileAddress) external returns (address latestAddress);

    /**
     * @dev manually called to update record
     */
    function update(address latestAddress) external;
}
