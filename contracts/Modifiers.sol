// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./diamond/libraries/LibDiamond.sol";

contract Modifiers {
  modifier onlyOwner() {
    LibDiamond.enforceIsContractOwner();
    _;
  }
}
