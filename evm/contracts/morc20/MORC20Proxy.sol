// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./MORC20Core.sol";

contract MORC20Proxy is MORC20Core {
    using SafeERC20 for IERC20;

    IERC20 internal immutable _underlying;
    uint256 public tokenDecimals;

    // total amount transferred to other chains
    uint256 public outAmount;

    constructor(address _token, address _mosAddress) MORC20Core(_mosAddress) {
        _underlying = IERC20(_token);

        tokenDecimals = uint256(IERC20Metadata(_token).decimals());
    }

    function currentChainSupply() public view virtual override returns (uint) {
        return _underlying.totalSupply() - outAmount;
    }

    function token() public view virtual override returns (address) {
        return address(_underlying);
    }

    function _destroyTokenFrom(
        address _fromAddress,
        uint256,
        bytes memory,
        uint256 _fromAmount
    ) internal virtual override returns (uint256 amount, uint256 decimals) {
        require(_fromAddress == _msgSender(), "MORC20Proxy: owner is not send caller");

        _fromAmount = _transferFrom(_fromAddress, address(this), _fromAmount);

        // check total outbound amount
        outAmount += _fromAmount;

        return (amount, tokenDecimals);
    }

    function _createTokenTo(
        address _receiverAddress,
        uint256,
        uint256 _fromAmount,
        uint256 _fromDecimals
    ) internal virtual override returns (uint256 amount, uint256 decimals) {
        if (tokenDecimals == _fromDecimals) {
            amount = _fromAmount;
        } else {
            amount = (_fromAmount * 10 ** tokenDecimals) / 10 ** _fromDecimals;
        }

        outAmount -= amount;

        // tokens are already in this contract, so no need to transfer
        if (_receiverAddress != address(this)) {
            _transferFrom(address(this), _receiverAddress, amount);
        }

        return (amount, tokenDecimals);
    }

    function _transferFrom(address _from, address _to, uint _amount) internal virtual override returns (uint) {
        uint before = _underlying.balanceOf(_to);
        if (_from == address(this)) {
            _underlying.safeTransfer(_to, _amount);
        } else {
            _underlying.safeTransferFrom(_from, _to, _amount);
        }

        return _underlying.balanceOf(_to) - before;
    }
}
