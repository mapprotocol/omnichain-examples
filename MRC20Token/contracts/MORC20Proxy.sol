// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./MORC20Core.sol";


contract MORC20Proxy is MORC20Core {
    using SafeERC20 for IERC20;

    IERC20 internal immutable interchainToken;
    uint256 public anchoringDecimals;

    // total amount is transferred from this chain to other chains, ensuring the total is less than uint64.max in sd
    uint public outboundAmount;

    constructor(address _token, address _mosAddress) MORC20Core( _mosAddress) {
        interchainToken = IERC20(_token);

        (bool success, bytes memory data) = _token.staticcall(
            abi.encodeWithSignature("decimals()")
        );
        require(success, "MORC20Proxy: failed to get token decimals");
        anchoringDecimals =uint256(abi.decode(data, (uint8)));
    }

    function currentChainSupply() public view virtual override returns (uint) {
        return interchainToken.totalSupply() - outboundAmount;
    }

    function token() public view virtual override returns (address) {
        return address(interchainToken);
    }

    function _sendCrossChainToken(
        address _fromAddress,
        uint256 ,
        bytes memory,
        uint256 _fromAmount
    ) internal virtual override returns (uint256 amount,uint256 decimals) {
        require(_fromAddress == _msgSender(), "ProxyOFT: owner is not send caller");

        _fromAmount = _transferFrom(_fromAddress, address(this), _fromAmount);

        // check total outbound amount
        outboundAmount += _fromAmount;

        return (amount,anchoringDecimals);
    }

    function _receiveCrossChainToken(
        address _receiveAddress,
        uint256 ,
        uint256 _amount,
        uint256 _decimals
    ) internal virtual override returns (uint256 amount,uint256 decimals) {
        amount = _amount * 10 ** anchoringDecimals / 10 ** _decimals;

        outboundAmount -= amount;

        // tokens are already in this contract, so no need to transfer
        if (_receiveAddress == address(this)) {
            return (amount,anchoringDecimals);
        }

        return (_transferFrom(address(this), _receiveAddress, amount),anchoringDecimals);
    }

    function _transferFrom(address _from, address _to, uint _amount) internal virtual override returns (uint) {
        uint before = interchainToken.balanceOf(_to);
        if (_from == address(this)) {
            interchainToken.safeTransfer(_to, _amount);
        } else {
            interchainToken.safeTransferFrom(_from, _to, _amount);
        }
        return interchainToken.balanceOf(_to) - before;
    }


}
