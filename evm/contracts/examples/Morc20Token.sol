// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../MRC20Token/MORC20Token.sol";

contract Morc20Token is MORC20Token {
    constructor(
        string memory _name,
        string memory _symbol,
        address _mosAddress,
        address _owner
    )
    MORC20Token(_name, _symbol,_mosAddress)
    {
        _transferOwnership(_owner);
    }

    function mint(address _receiveAddress,uint256 _amount) public virtual onlyOwner{
        _mint(_receiveAddress,_amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    function _transferOwnership(address _newOwner)
    internal
    virtual
    override
    {
        super._transferOwnership(_newOwner);
    }

}
