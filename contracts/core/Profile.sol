// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/introspection/ERC165.sol';
import '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import './IProfileV1.sol';
import '../bridge/IResolver.sol';
import '../util/Compat.sol';
import '../util/Signature.sol';

abstract contract Profile is IProfileV1, ERC165, Ownable {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;

    IResolver private _resolver = IResolver(address(0));
    mapping(address => address) private _profileContractCache;
    EnumerableSet.AddressSet private _followers;
    EnumerableSet.AddressSet private _following;
    mapping(address => bool) private _sentFollowRequests;
    mapping(address => bool) private _pendingFollowRequests;

    address private _root;
    address private _moved = address(0);
    address private _profileAddress;
    bytes private _signature = '';
    Counters.Counter private _nonce;
    mapping(uint256 => Counters.Counter) private _replyNonce;

    constructor(address _profile, address _rootContract) {
        _root = _rootContract;
        _profileAddress = _profile;
    }

    modifier onlyFromProfile() {
        require(Compat.supportsProfileV1(msg.sender), 'unsupported contract');
        require(Signature.verifyContract(IProfileV1(msg.sender)), 'unable to verify contract');
        _;
    }

    modifier notMoved() {
        require(_moved == address(0), 'contract is moved, functionality disabled');
        _;
    }

    /**
     * @dev check if a profile is moved to a new contract
     * @return address 0x0 if not moved, otherwise is the new contract address
     */
    function rootContractAddress() external view returns (address) {
        return _root;
    }

    /**
     * @dev check if a profile is moved to a new contract
     * @return address 0x0 if not moved, otherwise is the new contract address
     */
    function newContractAddress() external view returns (address) {
        return _moved;
    }

    /**
     * @dev this is represents the profile identity
     * @return address the canonical profile address.
     */
    function profileAddress() external view returns (address) {
        return _profileAddress;
    }

    /**
     * @dev the signature of `abi.encodePacked(contractAddress, profileAddress)` using profile key
     * @return signature signature of this profile.
     */
    function signature() external view returns (bytes memory) {
        return _signature;
    }

    /**
     * @notice others will call this function to send a follow request
     * @dev You can automaticly approve follow request by returns `Approved`.
     * Or automaticly reject the request. Or returns `Pending` to wait owner's operation.
     */
    function followRequest() external payable virtual onlyFromProfile notMoved returns (FollowRequestResult) {
        IProfileV1 _contract = IProfileV1(msg.sender);
        address _profile = _contract.profileAddress();
        _updateCache(_profile, address(_contract));
        _pendingFollowRequests[_profile] = true;

        emit PendingFollowEvent(_profile, address(_contract));

        return FollowRequestResult.Pending;
    }

    /**
     * @dev this is a "callback" of "followRequest" when it returns `Pending`.
     */
    function followResponse(FollowResponse result) external payable virtual onlyFromProfile notMoved {
        IProfileV1 _contract = IProfileV1(msg.sender);
        address _profile = _contract.profileAddress();
        _updateCache(_profile, address(_contract));

        require(_sentFollowRequests[_profile], 'Profile: follow request not found');
        if (result == FollowResponse.Approved) {
            _following.add(_profile);
            emit NewFollowingEvent(_profile, address(_contract));
        } else {
            emit FollowingRejectedEvent(_profile, address(_contract));
        }
        _sentFollowRequests[_profile] = false;
    }

    /**
     * @dev unfollow callback
     */
    function unfollowNotification() external virtual onlyFromProfile notMoved {
        IProfileV1 _contract = IProfileV1(msg.sender);
        address _profile = _contract.profileAddress();
        _followers.remove(_profile);
        if (!_following.contains(_profile)) {
            _removeCache(_profile);
        }
    }

    /**
     * @dev others will call this to reply to a posted message.
     */
    function replyTo(
        uint256 nonce,
        string calldata content,
        bytes calldata replySignature
    ) external virtual onlyFromProfile notMoved {
        IProfileV1 _contract = IProfileV1(msg.sender);
        address _profile = _contract.profileAddress();

        require(nonce < _nonce.current());
        Counters.Counter storage counter = _replyNonce[nonce];
        uint256 replyNonce = counter.current();

        require(Signature.verifyReply(_profileAddress, nonce, _profile, replyNonce, content, replySignature));

        emit ReplyEvent(nonce, replyNonce, _profile, content, replySignature);

        counter.increment();
    }

    /**
     * @dev get next nonce
     */
    function getNonce() external view returns (uint256) {
        return _nonce.current();
    }

    /**
     * @dev get next nonce of a post
     */
    function getReplyNonce(uint256 postNonce) external view returns (uint256) {
        require(postNonce < _nonce.current());
        return _replyNonce[postNonce].current();
    }

    /**
     * @dev complete a pending follow request
     */
    function completeFollowRequest(address _profile, FollowResponse result) public onlyOwner notMoved {
        require(_pendingFollowRequests[_profile], 'Profile: not found');

        IProfileV1 _contract = IProfileV1(_resolveProfile(_profile));
        _contract.followResponse(result);
        _updateCache(_profile, address(_contract));

        if (result == FollowResponse.Approved) {
            _followers.add(_profile);
            emit NewFollowerEvent(_profile, address(_contract));
        }

        _pendingFollowRequests[_profile] = false;
    }

    /**
     * @dev unfollow and notify
     */
    function unfollow(address _profile) public onlyOwner notMoved {
        require(_following.contains(_profile), 'Profile: not found');

        IProfileV1 _contract = IProfileV1(_resolveProfile(_profile));
        if (!_followers.contains(_profile)) {
            _removeCache(_profile);
        }

        // notify only, don't care about the result
        try _contract.unfollowNotification() {} catch {}

        _following.remove(_profile);

        emit UnFollowEvent(_profile, address(_contract));
    }

    /**
     * @dev make post
     */
    function post(string calldata content, bytes calldata postSignature) public onlyOwner notMoved {
        uint256 nonce = _nonce.current();

        // remove this to reduce gas cost if you have this check offline.
        require(Signature.verifyPost(_profileAddress, _nonce.current(), content, postSignature));

        emit PostEvent(nonce, _profileAddress, nonce, content, postSignature, postSignature);
        _nonce.increment();
    }

    /**
     * @dev make repost
     */
    function repost(
        address sourceProfile,
        uint256 sourceNonce,
        string calldata content,
        bytes calldata sourceSignature,
        bytes calldata postSignature
    ) public onlyOwner notMoved {
        uint256 nonce = _nonce.current();

        // verify repost, remove this to reduce gas cost if you have this check offline.
        require(Signature.verifyPost(sourceProfile, sourceNonce, content, sourceSignature));
        require(Signature.verifyRepost(_profileAddress, nonce, sourceProfile, sourceNonce, content, postSignature));

        emit PostEvent(nonce, sourceProfile, sourceNonce, content, sourceSignature, postSignature);
        _nonce.increment();
    }

    /**
     * @dev assign resolver
     */
    function setResolver(address resolver) public onlyOwner notMoved {
        require(Compat.supportsResolver(resolver), 'unsupported contract');
        _resolver = IResolver(resolver);
    }

    /**
     * @dev migerate contract
     */
    function moveContract(address newContract) public onlyOwner notMoved {
        require(Compat.supportsProfileV1(newContract), 'unsupported contract');
        IProfileV1 profile = IProfileV1(newContract);
        require(Signature.verifyContract(profile), 'unable to verify contract');
        require(_profileAddress == profile.profileAddress(), 'not same profile');
        _moved = newContract;
    }

    /**
     * @dev extract balance
     */
    function transfer(address payable _target, uint256 amount) public onlyOwner {
        _target.transfer(amount);
    }

    function _resolveProfile(address _profile) private returns (address) {
        address contractAddress = _profileContractCache[_profile];
        if (contractAddress != address(0)) {
            contractAddress = Compat.getLatestAddress(contractAddress);
            _profileContractCache[_profile] = contractAddress;
            if (address(_resolver) != address(0)) {
                // inform the resolver to help others
                _resolver.update(contractAddress);
            }
        }
        require(address(_resolver) != address(0), 'Profile: resolver disabled and not found in cache');
        return _resolver.resolve(_profile);
    }

    function _updateCache(address _profile, address _contract) private {
        _profileContractCache[_profile] = _contract;
    }

    function _removeCache(address _profile) private {
        _profileContractCache[_profile] = address(0);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        return interfaceId == Compat.PROFILE_V1_INTERFACE_ID || super.supportsInterface(interfaceId);
    }
}
