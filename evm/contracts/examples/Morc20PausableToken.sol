// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../extensions/Morc20Pausable.sol";

contract Morc20PausableToken is Morc20Pausable {
    constructor(
        string memory _name,
        string memory _symbol,
        address _mosAddress,
        uint256 _initialSupply
    )
    Morc20Pausable(_name, _symbol,_mosAddress)
    {
        _mint(msg.sender,_initialSupply);
    }

}
