// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../diamond/libraries/LibDiamond.sol";

/**
 * @title Utility contract for preventing reentrancy attacks
 */
abstract contract Ownable {
  modifier onlyOwner() {
    LibDiamond.enforceIsContractOwner();
    _;
  }
}
