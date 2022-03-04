//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "ds-test/test.sol";

import "./Claims.sol";

contract ClaimsTest is DSTest {
    function setUp() public {
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
