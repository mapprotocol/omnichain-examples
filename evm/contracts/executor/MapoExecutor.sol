// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@mapprotocol/mos/contracts/interface/IMOSV3.sol";
import "@mapprotocol/mos/contracts/interface/IMapoExecutor.sol";

abstract contract MapoExecutor is Ownable, IMapoExecutor {
    uint256 public constant MESSAGE_TYPE_MESSAGE = 0;
    uint256 public constant MESSAGE_TYPE_CALLDATE = 1;
    uint256 public constant INTERCHAIN_GASLIMIT = 50000;
    uint256 public constant gasLimitMin = 21000;
    uint256 public constant gasLimitMax = 10000000;

    IMOSV3 public mos;
    address public feeTokenAddress;
    mapping(uint256 => bytes) public trustedList;

    event SetTrustedAddress(uint256 toChainId, bytes toAddress);
    event SetFeeToken(address _feeToken);

    constructor(address _mosAddress) {
        require(_mosAddress != address(0), "MapoExecutor: invalid mos address");
        mos = IMOSV3(_mosAddress);
    }

    function mapoExecute(
        uint256 _fromChain,
        uint256 _toChain,
        bytes calldata _fromAddress,
        bytes32 _orderId,
        bytes calldata _message
    ) external virtual override returns(bytes memory newMessage){
        require(_msgSender() == address(mos), "MapoExecutor: invalid mos caller");

        bytes memory tempFromAddress = trustedList[_fromChain];

        require(_fromAddress.length == tempFromAddress.length && tempFromAddress.length > 0 && keccak256(_fromAddress) == keccak256(tempFromAddress),
            "MapoExecutor: invalid source chain address");

        newMessage = _execute(_fromChain, _toChain, _fromAddress, _orderId, _message);
    }

    function _execute(
        uint256 _fromChain,
        uint256 _toChain,
        bytes memory _fromAddress,
        bytes32 _orderId,
        bytes memory _message
    ) internal virtual returns(bytes memory);

    function _mosTransferOut(
        uint256 _toChain,
        uint256 _toType,
        bytes memory _payload,
        uint256 _gasLimit,
        address _feeToken
    )internal virtual returns(bytes32) {
        bytes memory tempFromAddress = trustedList[_toChain];
        require(tempFromAddress.length > 0, "MapoExecutor: invalid remote trust address");

        bytes memory messageDataBytes;
        if (_toType == MESSAGE_TYPE_MESSAGE) {
            messageDataBytes = abi.encode(false, IMOSV3.MessageType.MESSAGE, tempFromAddress, _payload, _gasLimit, 0);
        } else if(_toType == MESSAGE_TYPE_CALLDATE) {
            messageDataBytes = abi.encode(false, IMOSV3.MessageType.CALLDATA, tempFromAddress, _payload, _gasLimit, 0);
        } else {
            require(false, "MapoExecutor: invalid message type");
        }

        (uint256 fee,) = mos.getMessageFee(_toChain, _feeToken, _gasLimit);

        if (_feeToken == address(0)){
            return mos.transferOut{value:fee}(_toChain, messageDataBytes, _feeToken);
        }else{
            SafeERC20.safeApprove(IERC20(_feeToken),address(mos),fee);
            SafeERC20.safeTransferFrom(IERC20(_feeToken),msg.sender,address(this),fee);
            return mos.transferOut(_toChain, messageDataBytes, _feeToken);
        }

    }

    function _checkMessageFee(uint256 _toChain, address _feeToken, uint256 _gasLimit) internal view virtual {
        require(_gasLimit >= gasLimitMin && _gasLimit <= gasLimitMax,"MapoExecutor: execution gas out of range");
        (uint256 fee,) = mos.getMessageFee(_toChain, _feeToken, _gasLimit);
        require(fee > 0, "MapoExecutor: invalid fee");
        if(_feeToken == address(0)){
            require(msg.value >= fee, "MapoExecutor: insufficient fee" );
        }else{
            require(IERC20(_feeToken).balanceOf(msg.sender) >= fee, "MapoExecutor: insufficient token");
        }
    }


    function getTrustedAddress(uint256 _toChainId) external view returns(bytes memory){
        return trustedList[_toChainId];
    }


    function setTrustedAddress(uint256 _toChainId,bytes memory _toAddress) external onlyOwner {
        trustedList[_toChainId] = _toAddress;
        emit SetTrustedAddress(_toChainId, _toAddress);
    }


    function setFeeToken(address _feeToken)external onlyOwner{
        feeTokenAddress = _feeToken;
        emit SetFeeToken(_feeToken);
    }
}
