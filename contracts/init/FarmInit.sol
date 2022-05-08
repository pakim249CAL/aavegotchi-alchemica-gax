// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../libraries/FarmStorage.sol";

contract FarmInit {
  function init(
    address rewardToken,
    uint256 startBlock,
    uint256 decayPeriod
  ) external {
    FarmStorage.Layout storage s = FarmStorage.layout();
    s.rewardToken = IERC20(rewardToken);
    s.startBlock = startBlock;
    s.decayPeriod = decayPeriod;
  }
}
