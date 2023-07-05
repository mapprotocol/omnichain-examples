// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../extensions/MORC20Cappded.sol";

contract MORC20CappdedToken is MORC20Cappded {

    constructor(
        string memory _name,
        string memory _symbol,
        address _mosAddress,
        uint256 _initialSupply,
        address _owner
    )
    MORC20Cappded(_name, _symbol,_initialSupply,_mosAddress)
    {
        _transferOwnership(_owner);
        _mint(_owner,_initialSupply);
    }

}
