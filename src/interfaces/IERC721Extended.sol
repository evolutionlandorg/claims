//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IERC721Extended {
    function batchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids
    ) external;
}
