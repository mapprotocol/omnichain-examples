// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./interfaces/IMORC20.sol";
import "./interfaces/IMorc20Receiver.sol";
import "./MosServer/MosServer.sol";
import "./lib/ExcessivelySafeCall.sol";

abstract contract MORC20Core is MosServer, ERC165,IMORC20 {

    using ExcessivelySafeCall for address;

    uint256 public constant INTERCHAIN_T = 0;
    uint256 public constant INTERCHAIN_C = 1;

    mapping(bytes32 => bool) public orderList;

    event NonContractAddress(address receiveAddress);
    event InterchainTransfer(address fromAddress,uint256 toChainId,bytes toAddress,uint256 fromAmount,uint256 decimals);
    event ReceiveToken(uint256 fromChain,bytes fromAddress,address receiveAddress,uint256 amount);
    event ReceiveTokenAndCall(uint256 indexed fromchain,address indexed srcAddress,bytes32 indexed orderId,bytes32 callData);
    event ReceiveTokenAndCallError(uint256 indexed fromchain,address indexed srcAddress,bytes32 indexed orderId,bytes callData,bytes reason);

    event TestTransfer(bytes payload);
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

    function interchainTransferAndCall(
        address _fromAddress,
        uint256 _toChainId,
        bytes memory _toAddress,
        uint256 _fromAmount,
        address _feeToken,
        uint256 _gasLimit,
        bytes memory _messageData
    ) external payable virtual override {

        _interchainTransferAndCall(_fromAddress,_toChainId,_toAddress,_fromAmount,_feeToken,_gasLimit,_messageData);
    }


    function estimateFee(uint256 _toChain, address _feeToken, uint256 _gasLimit) public view virtual override returns (uint256 fee) {
        return _estimateFee(_toChain,_feeToken,_gasLimit);
    }


    function callMorc20Receiver(uint256 _fromChainId, bytes memory _fromAddress, uint256 _amount, address _srcAddress, address _receiveAddress, bytes32 _orderId, bytes calldata _message) public virtual {

        require(_msgSender() == address(this), "MORC20Core: caller must be MORC20Core");

        // send
        uint256 amount = _transferFrom(address(this), _receiveAddress, _amount);
        emit ReceiveToken(_fromChainId,_fromAddress,_receiveAddress,amount);

        // call
        IMorc20Receiver(_receiveAddress).morc20Receiver{gas:gasleft()}(_fromChainId, _fromAddress, _amount,  _srcAddress,_orderId, _message);
    }

    function _interchainTransfer(
        address _fromAddress,
        uint256 _toChainId,
        bytes memory _toAddress,
        uint256 _fromAmount,
        address _feeToken,
        uint256 _gasLimit
    ) internal virtual  {
        (uint256 amount,uint256 decimals) = _sendCrossChainToken(_fromAddress, _toChainId, _toAddress, _fromAmount); // amount returned should not have dust
        require(amount > 0, "MORC20Core: amount too small");

        bytes memory prePayload =abi.encode(_fromAddress,_toAddress,amount,decimals);

        bytes memory payload = abi.encode(INTERCHAIN_T,prePayload);

        _mosTransferOut(_toChainId,MESSAGE_TYPE_MESSAGE,payload,_gasLimit,_feeToken);

        emit InterchainTransfer(_fromAddress,_toChainId,_toAddress,_fromAmount,decimals);
    }

    function _interchainTransferAndCall(
        address _fromAddress,
        uint256 _toChainId,
        bytes memory _toAddress,
        uint256 _fromAmount,
        address _feeToken,
        uint256 _gasLimit,
        bytes memory _messageData
    )internal virtual {
        (uint256 amount,uint256 decimals) = _sendCrossChainToken(_fromAddress, _toChainId, _toAddress, _fromAmount); // amount returned should not have dust
        require(amount > 0, "MORC20Core: amount too small");

        bytes memory prePayload =abi.encode(msg.sender,_toAddress,amount,decimals,_messageData);

        bytes memory payload = abi.encode(INTERCHAIN_C,prePayload);

        _mosTransferOut(_toChainId,MESSAGE_TYPE_MESSAGE,payload,_gasLimit,_feeToken);

        emit InterchainTransfer(_fromAddress,_toChainId,_toAddress,_fromAmount,decimals);
    }

    function _interchainTransferExecute(
        uint256 _fromChain,
        bytes memory _fromAddress,
        bytes32,
        bytes memory _payload
    ) internal virtual {
        (,bytes memory receiveBytes,uint256 amount,uint256 decimals) = abi.decode(_payload,(address,bytes,uint256,uint256));

        address receiveAddress = _fromBytes(receiveBytes);

        _receiveCrossChainToken(receiveAddress,_fromChain,amount,decimals);

        emit ReceiveToken(_fromChain,_fromAddress,receiveAddress,amount);
    }

    function _interchainTransferAndCallExecute(
        uint256 _fromChain,
        bytes memory _fromAddress,
        bytes32 _orderId,
        bytes memory _payload
    )internal virtual {
        (address srcAddress,bytes memory receiveBytes,uint256 amount,uint256 decimals,bytes memory messageData) = abi.decode(_payload,(address,bytes,uint256,uint256,bytes));

        address receiveAddress = _fromBytes(receiveBytes);

        (uint256 amount_,) = _receiveCrossChainToken(address(this),_fromChain,amount,decimals);

        if (!_isContract(receiveAddress)) {
            emit NonContractAddress(receiveAddress);
            return;
        }

        bytes memory  callMorc20ReceiverSelector = abi.encodeWithSelector(this.callMorc20Receiver.selector, _fromChain, _fromAddress, amount_, srcAddress,receiveAddress, _orderId, messageData);

        (bool success, bytes memory reason) = address(this).excessivelySafeCall(gasleft(), 150, callMorc20ReceiverSelector);

        if(success){
            emit ReceiveTokenAndCall(_fromChain,srcAddress,_orderId,keccak256(callMorc20ReceiverSelector));
        }else{
            emit ReceiveTokenAndCallError(_fromChain,srcAddress,_orderId,callMorc20ReceiverSelector,reason);
        }

    }

    function _isContract(address _user) internal view returns (bool) {
        return _user.code.length > 0;
    }

    function _tokenExecute(
        uint256 _fromChain,
        uint256 ,
        bytes memory _fromAddress,
        bytes32 _orderId,
        bytes memory _message
    ) internal virtual override {

        require(!orderList[_orderId],"MORC20Core:invalid orderId");

        (uint256 interchainType,bytes memory payload) = abi.decode(_message,(uint256,bytes));

        if(interchainType == INTERCHAIN_T){
            emit TestTransfer(payload);
            _interchainTransferExecute(_fromChain,_fromAddress,_orderId,payload);
        }else if(interchainType == INTERCHAIN_C){
            _interchainTransferAndCallExecute(_fromChain,_fromAddress,_orderId,payload);
        }else{
            revert("MORC20Core: unknown packet type");
        }

        orderList[_orderId] = true;

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
