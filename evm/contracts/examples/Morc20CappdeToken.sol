// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../extensions/Morc20Cappde.sol";

contract Morc20CappdeToken is Morc20Cappde {

    constructor(
        string memory _name,
        string memory _symbol,
        address _mosAddress,
        uint256 _initialSupply,
        address _owner
    )
    Morc20Cappde(_name, _symbol,_initialSupply,_mosAddress)
    {
        _transferOwnership(_owner);
        _mint(_owner,_initialSupply);
    }

    function _transferOwnership(address _newOwner)
    internal
    virtual
    override
    {
        super._transferOwnership(_newOwner);
    }

}
