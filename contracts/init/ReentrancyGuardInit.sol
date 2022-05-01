// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../libraries/ReentrancyGuardStorage.sol";

/** @notice Ultimately optional reentrancy guard init contract
 * @dev Initiates the status variable to 1 to decrease the gas cost
 * of the first transaction that uses the reentracncy guard */
contract ReentrancyGuardInit {
  function init() external {
    ReentrancyGuardStorage.Layout storage s = ReentrancyGuardStorage
      .layout();
    s.status = 1;
  }
}
