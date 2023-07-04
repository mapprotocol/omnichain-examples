// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../MRC20Token/MORC20Token.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract  Morc20BurnableToken is MORC20Token, ERC20Burnable {

    constructor(
        string memory _name,
        string memory _symbol,
        address _mosAddress,
        uint256 _initialSupply,
        address _owner
    )
    MORC20Token(_name, _symbol,_mosAddress)
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
