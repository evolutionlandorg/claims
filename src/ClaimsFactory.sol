//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import './Claims.sol';

contract ClaimsFactory {
    event Create(address claims);
    event Register(bytes32 org, address claims);

    address public setter;

    mapping(bytes32 => address) public orgOf;
    bytes32[] public allOrgs;

    constructor() {
        setter = msg.sender;
    }

    function allOrgsLength() public view returns (uint) {
        return allOrgs.length;
    }

    function setSetter(address _setter) public {
        require(msg.sender == setter, "FORBIDDEN");
        setter = _setter;
    }

    function register(bytes32 org, address claims) public {
        require(msg.sender == setter, "FORBIDDEN");
        _add(org, claims);
    }

    function create(bytes32 org, address admin) public {
        Claims claims = new Claims();
        claims.initialize(admin);
        emit Create(address(claims));
        _add(org, address(claims));
    }

    function _add(bytes32 org, address claims) internal {
        require(orgOf[org] == address(0), "EXISTS");
        orgOf[org] = claims;
        allOrgs.push(org);
        emit Register(org, claims);
    }
}
