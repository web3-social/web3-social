// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * Interface of the ProfileV1 standard of web3-social protocol.
 */
interface IProfileV1 is IERC165 {

    event FollowEvent();
    event UnFollowEvent();
    event PostEvent(uint256 index, string content);

    enum FollowRequestResult { Approved, Pending, Rejected }

    /**
     * @dev check if a profile is moved to a new contract
     * @return address 0x0 if not moved, otherwise is the new contract address
     */
    function newContractAddress() external view returns (address);
   
    /**
     * @dev this is represents the profile identity
     * @return address the canonical profile address.
     */
    function profileAddress() external view returns (address);

    /**
     * @dev the signature of `0x{profileAddress:x}:0x{contractAddress:x}` using profile key
     * @return signature signature of this profile.
     */
    function signature() external view returns (bytes memory);

    /**
     * @notice others will call this function to send a follow request
     * @dev You can automaticly approve follow request by returns `Approved`.
     * Or automaticly reject the request. Or returns `Pending` to wait owner's operation.
     */
    function followRequest() external payable returns (FollowRequestResult);

    /**
     * @dev this is a "callback" of "followRequest" when it returns `Pending`.
     */
    function followResponse(FollowRequestResult result) external payable;

    /**
     * @dev others will call this to reply to a posted message.
     */
    function replyTo(uint256 index, string calldata content) external;
}