// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../core/Profile.sol';

contract TestProfile is Profile {
    constructor(address _profile) Profile(_profile, address(0)) {}
}
