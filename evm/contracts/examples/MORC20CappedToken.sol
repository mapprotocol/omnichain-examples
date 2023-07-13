// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../extensions/MORC20Capped.sol";

contract MORC20CappedToken is MORC20Capped {

    constructor(
        string memory _name,
        string memory _symbol,
        address _mosAddress,
        uint256 _initialSupply,
        uint256 _capped,
        address _owner
    )
    MORC20Capped(_name, _symbol, _capped, _mosAddress)
    {
        _transferOwnership(_owner);
        _mint(_owner,_initialSupply);
    }

}
