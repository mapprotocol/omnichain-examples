// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@mapprotocol/mos/contracts/interface/IMOSV3.sol";

contract OAppSourceSender is Ownable {
    IMOSV3 public mos;

    uint256 public cumulativeResult;

    bytes32 public constant CROSS_CHIAN_MESSAGE = keccak256("Message(bytes32,bytes)");

    receive() external payable {}

    constructor(address _mos) {
        mos = IMOSV3(_mos);
    }

    function crossChainAdd(uint256 _number) external {
        require(msg.sender == address(mos), "do not have permission");
        cumulativeResult += _number;
    }

    function _getCalldataMessageData(uint256 _number, bytes memory _target) internal pure returns (bytes memory) {
        bytes memory payload = abi.encodeWithSelector(OAppSourceSender.crossChainAdd.selector, _number);

        IMOSV3.MessageData memory messageData = IMOSV3.MessageData(
            false,
            IMOSV3.MessageType.CALLDATA,
            _target,
            payload,
            500000,
            0
        );

        return abi.encode(messageData);
    }

    function _getMessageMessageData(uint256 _number, bytes memory _target) internal pure returns (bytes memory) {
        bytes memory prePayload = abi.encode(_number);
        bytes memory payload = abi.encode(CROSS_CHIAN_MESSAGE, prePayload);

        IMOSV3.MessageData memory messageData = IMOSV3.MessageData(
            false,
            IMOSV3.MessageType.MESSAGE,
            _target,
            payload,
            500000,
            0
        );

        return abi.encode(messageData);
    }

    function getTransferOutFee(uint256 _toChainId) public view returns (uint256) {
        (uint256 amount, ) = mos.getMessageFee(_toChainId, address(0), 500000);
        return amount;
    }

    function sendCalldataCrossChain(
        uint256 _toChainId,
        uint256 _number,
        bytes memory _target
    ) external payable returns (bytes32) {
        bytes memory messageData = _getCalldataMessageData(_number, _target);

        uint256 fee = getTransferOutFee(_toChainId);

        bytes32 orderId = mos.transferOut{value: fee}(_toChainId, messageData, address(0));

        return orderId;
    }

    function sendMessageCrossChain(
        uint256 _toChainId,
        uint256 _number,
        bytes memory _target
    ) external payable returns (bytes32) {
        bytes memory messageData = _getMessageMessageData(_number, _target);

        uint256 fee = getTransferOutFee(_toChainId);

        bytes32 orderId = mos.transferOut{value: fee}(_toChainId, messageData, address(0));

        return orderId;
    }

    function sendCrossChain(
        uint256 _toChainId,
        uint256 _number,
        bytes memory _target,
        uint256 _tag
    ) external returns (bytes32) {
        bytes memory messageData;
        if (_tag == 1) {
            messageData = _getMessageMessageData(_number, _target);
        } else {
            messageData = _getCalldataMessageData(_number, _target);
        }

        uint256 fee = getTransferOutFee(_toChainId);

        bytes32 orderId = mos.transferOut{value: fee}(_toChainId, messageData, address(0));

        return orderId;
    }
}
