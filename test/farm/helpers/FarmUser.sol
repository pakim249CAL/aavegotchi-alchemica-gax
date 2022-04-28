// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "../TestSetupFarm.t.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FarmUser {
  function transfer(
    address token,
    address account,
    uint256 amount
  ) external {
    IERC20(token).transfer(account, amount);
  }

  function approve(
    address token,
    address account,
    uint256 amount
  ) external {
    IERC20(token).approve(account, amount);
  }

  function transferFrom(
    address token,
    address from,
    address to,
    uint256 amount
  ) external {
    IERC20(token).transferFrom(from, to, amount);
  }
}
