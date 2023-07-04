// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../extensions/Morc20Pausable.sol";

contract Morc20PausableToken is Morc20Pausable {
    constructor(
        string memory _name,
        string memory _symbol,
        address _mosAddress,
        uint256 _initialSupply,
        address _owner
    )
    Morc20Pausable(_name, _symbol,_mosAddress)
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
