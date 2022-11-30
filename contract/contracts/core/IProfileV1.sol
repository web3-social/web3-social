// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/introspection/IERC165.sol';

/**
 * Interface of the ProfileV1 standard of web3-social protocol.
 */
interface IProfileV1 is IERC165 {
    /**
     * @dev emit when you got a new follow reqeust
     */
    event PendingFollowEvent(address indexed _fromProfile, address _currentContract);
    /**
     * @dev emit when you are following a new Profile
     */
    event NewFollowingEvent(address indexed _followingProfile, address _currentContract);
    /**
     * @dev emit when you got a new follower
     */
    event NewFollowerEvent(address indexed _followerProfile, address _currentContract);
    /**
     * @dev emit when others rejected your follow request
     */
    event FollowingRejectedEvent(address indexed _followingProfile, address _currentContract);
    /**
     * @dev emit when you unfollow someone
     */
    event UnFollowEvent(address indexed _followingProfile, address _currentContract);
    /**
     * @dev emit when you post/repost
     * signature is correspond to
     * `personal_sign(abi.encode(profile, nonce, sourceProfile, sourceNonce, keccak256(abi.encodePacked(content)))`
     */
    event PostEvent(
        uint256 indexed nonce,
        address indexed sourceProfile,
        uint256 indexed sourceNonce,
        string content,
        bytes sourceSignature,
        bytes signature
    );
    /**
     * @dev emit when others reply you
     * signature is correspond to
     * `personal_sign(abi.encode(postProfile, postNonce, sourceProfile, replyNonce, keccak256(abi.encodePacked(content)))`
     */
    event ReplyEvent(
        address indexed postProfile,
        uint256 indexed postNonce,
        address indexed sourceProfile,
        uint256 replyNonce,
        string content,
        bytes replySignature
    );

    enum FollowRequestResult {
        Pending,
        Approved,
        Rejected
    }
    enum FollowResponse {
        Approved,
        Rejected
    }

    /**
     * @dev check if a profile is moved to a new contract
     * @return address 0x0 if not moved, otherwise is the new contract address
     */
    function rootContractAddress() external view returns (address);

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
     * @dev the personal_sign of `abi.encodePacked(contractAddress, profileAddress)` using profile key
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
    function followResponse(FollowResponse response) external payable;

    /**
     * @dev unfollow callback
     */
    function unfollowNotification() external;

    /**
     * @dev others will call this to reply to a posted message.
     */
    function replyTo(uint256 nonce, string calldata content, bytes calldata replySignature) external;

    /**
     * @dev get next nonce
     */
    function getNonce() external view returns (uint256);

    /**
     * @dev get next nonce of a post
     */
    function getReplyNonce(uint256 postNonce) external view returns (uint256);
}
