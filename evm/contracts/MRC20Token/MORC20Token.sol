// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./MORC20Core.sol";

contract MORC20Token is MORC20Core, ERC20 {

    uint256 public anchoringDecimals;

    constructor(string memory _name, string memory _symbol, address _mosAddress) ERC20(_name, _symbol) MORC20Core(_mosAddress) {
         anchoringDecimals = uint256(decimals());
    }

    function currentChainSupply() public view virtual override returns (uint) {
        return totalSupply();
    }

    function token() public view virtual override returns (address) {
        return address(this);
    }

    function _sendCrossChainToken(
        address _fromAddress,
        uint256 ,
        bytes memory,
        uint256 _fromAmount
    ) internal virtual override returns (uint256 amount,uint256 decimals){
        address spender = _msgSender();
        if (_fromAddress != spender) _spendAllowance(_fromAddress, spender, _fromAmount);
        _burn(_fromAddress, _fromAmount);
        return (_fromAmount,anchoringDecimals);
    }

    function _receiveCrossChainToken(
        address _receiveAddress,
        uint256 ,
        uint256 _amount,
        uint256 _decimals
    ) internal virtual override returns (uint256 amount,uint256 decimals){
        amount = _amount * 10 ** anchoringDecimals / 10 ** _decimals;
        _mint(_receiveAddress, amount);
        return (amount,anchoringDecimals);
    }

    function _transferFrom(address _from, address _to, uint256 _amount) internal virtual override returns (uint256) {
        address spender = _msgSender();
        // if transfer from this contract, no need to check allowance
        if (_from != address(this) && _from != spender) _spendAllowance(_from, spender, _amount);
        _transfer(_from, _to, _amount);
        return _amount;
    }

}
