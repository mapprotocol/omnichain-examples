// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev Interface of the IMORC20 core standard
 */
interface IMORC20  is IERC165 {

    event InterchainTransfer(bytes32 indexed orderId,address fromAddress,uint256 toChainId,bytes toAddress,uint256 fromAmount,uint256 decimals);

    event ReceiveToken(bytes32 indexed orderId,uint256 fromChain,bytes fromAddress,address receiveAddress,uint256 amount);
    event ReceiveTokenAndCall(uint256 indexed fromchain,address indexed srcAddress,bytes32 indexed orderId,bytes32 callData);
    event ReceiveTokenAndCallError(uint256 indexed fromchain,address indexed srcAddress,bytes32 indexed orderId,bytes callData,bytes reason);


    function estimateFee(uint256 toChain, address feeToken, uint256 gasLimit) external view returns (uint256 fee);

    /**
     * @dev returns the circulating amount of tokens on current chain
     */
    function currentChainSupply() external view returns (uint);

    /**
     * @dev returns the address of the ERC20 token
     */
    function token() external view returns (address);


    function interchainTransfer(
        address _fromAddress,
        uint256 _toChainId,
        bytes memory _toAddress,
        uint256 _fromAmount,
        address _feeToken
    ) external payable;

    function interchainTransferAndCall(
        address _fromAddress,
        uint256 _toChainId,
        bytes memory _toAddress,
        uint256 _fromAmount,
        address _feeToken,
        uint256 _gasLimit,
        bytes memory _messageData
    ) external payable;

}
