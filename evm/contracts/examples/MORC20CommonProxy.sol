// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../morc20/MORC20Proxy.sol";

contract MORC20CommonProxy is MORC20Proxy {
    constructor(address _token, address _mosAddress, address _owner) MORC20Proxy(_token, _mosAddress) {
        _transferOwnership(_owner);
    }
}
