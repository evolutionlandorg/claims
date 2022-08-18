// hevm: flattened sources of src/interfaces/IERC721Extended.sol
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

////// src/interfaces/IERC721Extended.sol
/* pragma solidity ^0.8.11; */

interface IERC721Extended {
    function batchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids
    ) external;
}

