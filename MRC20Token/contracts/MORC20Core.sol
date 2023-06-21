// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./interfaces/IMORC20.sol";
import "./MosServer/MosServer.sol";

abstract contract MORC20Core is MosServer, ERC165,IMORC20 {

    mapping(bytes32 => bool) public orderList;


    event InterchainTransfer(address _fromAddress,uint256 _toChainId,bytes _toAddress,uint256 _fromAmount,uint256 decimals);
    event ReceiveToken(uint256 _fromChain,bytes _fromAddress,address receiveAddress,uint256 amount,uint256 decimals);

    constructor(address _mosAddress) MosServer(_mosAddress) {

    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IMORC20).interfaceId || super.supportsInterface(interfaceId);
    }


    function interchainTransfer(
        address _fromAddress,
        uint256 _toChainId,
        bytes memory _toAddress,
        uint256 _fromAmount,
        address _feeToken
    ) public payable virtual override {
        _interchainTransfer(_fromAddress, _toChainId, _toAddress, _fromAmount,_feeToken,INTERCHAIN_GASLIMIT);

    }


    function estimateFee(uint256 _toChain, address _feeToken, uint256 _gasLimit) public view virtual override returns (uint256 fee) {
        return _estimateFee(_toChain,_feeToken,_gasLimit);
    }


    function _interchainTransfer(
        address _fromAddress,
        uint256 _toChainId,
        bytes memory _toAddress,
        uint256 _fromAmount,
        address _feeToken,
        uint256 _gasLimit
    ) internal virtual returns (uint256 amount) {
        uint256 decimals;
        (amount,decimals) = _sendCrossChainToken(_fromAddress, _toChainId, _toAddress, _fromAmount); // amount returned should not have dust
        require(amount > 0, "MORC20Core: amount too small");

        bytes memory payload =abi.encode(_fromAddress,_toAddress,amount,decimals);

        _mosTransferOut(_toChainId,MESSAGE_TYPE_MESSAGE,payload,_gasLimit,_feeToken);

        emit InterchainTransfer(_fromAddress,_toChainId,_toAddress,_fromAmount,decimals);
    }


    function _tokenExecute(
        uint256 _fromChain,
        uint256 ,
        bytes memory _fromAddress,
        bytes32 _orderId,
        bytes memory _message
    ) internal virtual override {

        require(!orderList[_orderId],"MORC20Core:invalid orderId");

        (,bytes memory receiveBytes,uint256 amount,uint256 decimals) = abi.decode(_message,(address,bytes,uint256,uint256));

        address receiveAddress = _fromBytes(receiveBytes);

        _receiveCrossChainToken(receiveAddress,_fromChain,amount,decimals);

        orderList[_orderId] = true;

        emit ReceiveToken(_fromChain,_fromAddress,receiveAddress,amount,decimals);
    }

    function _fromBytes(bytes memory bys) internal pure returns (address addr){
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function _estimateFee(uint256 _toChain, address _feeToken, uint256 _gasLimit) internal view virtual returns (uint256 fee) {
        (fee,) = mos.getMessageFee(_toChain, _feeToken,_gasLimit);
        return fee;
    }

    function _sendCrossChainToken(
        address _fromAddress,
        uint256 _toChainId,
        bytes memory _toAddress,
        uint256 _fromAmount
    ) internal virtual returns (uint256 amount,uint256 decimals);

    function _receiveCrossChainToken(
        address _receiveAddress,
        uint256 _srcChainId,
        uint256 _amount,
        uint256 _decimals
    ) internal virtual returns (uint256 amount,uint256 decimals);

    function _transferFrom(address _from, address _to, uint256 _amount) internal virtual returns (uint256);

    function currentChainSupply() public view virtual override returns (uint);

    function token() public view virtual override returns (address);
}
