// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../extensions/MORC20Pausable.sol";

contract MORC20PausableToken is MORC20Pausable {
    constructor(
        string memory _name,
        string memory _symbol,
        address _mosAddress,
        uint256 _initialSupply,
        address _owner
    )
    MORC20Pausable(_name, _symbol,_mosAddress)
    {
        _transferOwnership(_owner);
        _mint(_owner,_initialSupply);
    }

}
