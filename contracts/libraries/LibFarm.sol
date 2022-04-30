// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { FarmStorage, PoolInfo, UserInfo } from "./FarmStorage.sol";

// Farm distributes the ERC20 rewards based on staked LP to each user.
//
// Forked from https://github.com/SashimiProject/sashimiswap/blob/master/contracts/MasterChef.sol
// Modified by Manhattan Finance to work for non-mintable ERC20.
library LibFarm {
  using SafeERC20 for IERC20;

  event Deposit(
    address indexed user,
    uint256 indexed pid,
    uint256 amount
  );
  event Withdraw(
    address indexed user,
    uint256 indexed pid,
    uint256 amount
  );
  event EmergencyWithdraw(
    address indexed user,
    uint256 indexed pid,
    uint256 amount
  );
  event Harvest(address indexed user, uint256 amount);

  function s() private pure returns (FarmStorage.Layout storage fs) {
    return FarmStorage.layout();
  }

  // Fund the farm, increase the end block
  function fund(uint256 _amount) internal {
    require(
      block.number < s().endBlock,
      "fund: too late, the farm is closed"
    );

    s().rewardToken.safeTransferFrom(
      address(msg.sender),
      address(this),
      _amount
    );
    s().endBlock += _amount / s().rewardPerBlock;
  }

  // Add a new lp to the pool. Can only be called by the owner.
  // DO NOT add the same LP token more than once. Rewards will be messed up if you do.
  function add(
    uint256 _allocPoint,
    IERC20 _lpToken,
    bool _withUpdate
  ) internal {
    require(
      !s().poolTokens[address(_lpToken)],
      "add: LP token already added"
    );
    s().poolTokens[address(_lpToken)] = true;
    if (_withUpdate) {
      massUpdatePools();
    }
    uint256 lastRewardBlock = block.number > s().startBlock
      ? block.number
      : s().startBlock;
    s().totalAllocPoint += _allocPoint;
    s().poolInfo.push(
      PoolInfo({
        lpToken: _lpToken,
        allocPoint: _allocPoint,
        lastRewardBlock: lastRewardBlock,
        accERC20PerShare: 0
      })
    );
  }

  // Update the given pool's ERC20 allocation point. Can only be called by the owner.
  function set(
    uint256 _pid,
    uint256 _allocPoint,
    bool _withUpdate
  ) internal {
    require(
      s().poolTokens[address(s().poolInfo[_pid].lpToken)],
      "set: LP token not added"
    );
    if (_withUpdate) {
      massUpdatePools();
    }
    s().totalAllocPoint =
      s().totalAllocPoint -
      s().poolInfo[_pid].allocPoint +
      _allocPoint;
    s().poolInfo[_pid].allocPoint = _allocPoint;
  }

  // Update reward variables for all pools. Be careful of gas spending!
  function massUpdatePools() internal {
    uint256 length = s().poolInfo.length;
    for (uint256 pid = 0; pid < length; ) {
      updatePool(pid);
      unchecked {
        ++pid;
      }
    }
  }

  // Update reward variables of the given pool to be up-to-date.
  function updatePool(uint256 _pid) internal {
    PoolInfo storage pool = s().poolInfo[_pid];
    uint256 lastBlock = block.number < s().endBlock
      ? block.number
      : s().endBlock;

    if (lastBlock <= pool.lastRewardBlock) {
      return;
    }
    uint256 lpSupply = pool.lpToken.balanceOf(address(this));
    if (lpSupply == 0) {
      pool.lastRewardBlock = lastBlock;
      return;
    }

    uint256 nrOfBlocks = lastBlock - pool.lastRewardBlock;
    uint256 erc20Reward = (nrOfBlocks *
      s().rewardPerBlock *
      pool.allocPoint) / s().totalAllocPoint;

    pool.accERC20PerShare =
      ((pool.accERC20PerShare + erc20Reward) * 1e12) /
      lpSupply;
    pool.lastRewardBlock = block.number;
  }

  // Deposit LP tokens to Farm for ERC20 allocation.
  function deposit(uint256 _pid, uint256 _amount) internal {
    PoolInfo storage pool = s().poolInfo[_pid];
    UserInfo storage user = s().userInfo[_pid][msg.sender];

    updatePoolAndHarvest(msg.sender, _pid);

    if (_amount > 0) {
      pool.lpToken.safeTransferFrom(
        address(msg.sender),
        address(this),
        _amount
      );
      user.amount = user.amount + _amount;
    }
    emit Deposit(msg.sender, _pid, _amount);
  }

  // Withdraw LP tokens from Farm.
  function withdraw(uint256 _pid, uint256 _amount) internal {
    PoolInfo storage pool = s().poolInfo[_pid];
    UserInfo storage user = s().userInfo[_pid][msg.sender];
    require(
      user.amount >= _amount,
      "withdraw: can't withdraw more than deposit"
    );

    updatePoolAndHarvest(msg.sender, _pid);

    user.amount = user.amount - _amount;
    pool.lpToken.safeTransfer(address(msg.sender), _amount);
    emit Withdraw(msg.sender, _pid, _amount);
  }

  // Withdraw without caring about rewards. EMERGENCY ONLY.
  function emergencyWithdraw(uint256 _pid) internal {
    PoolInfo storage pool = s().poolInfo[_pid];
    UserInfo storage user = s().userInfo[_pid][msg.sender];
    pool.lpToken.safeTransfer(address(msg.sender), user.amount);
    emit EmergencyWithdraw(msg.sender, _pid, user.amount);
    user.amount = 0;
    user.rewardDebt = 0;
  }

  // Updates the pool and harvests reward tokens
  function updatePoolAndHarvest(address _to, uint256 _pid) internal {
    PoolInfo storage pool = s().poolInfo[_pid];
    UserInfo storage user = s().userInfo[_pid][_to];
    updatePool(_pid);

    uint256 userReward = (user.amount * pool.accERC20PerShare) / 1e12;

    if (user.amount > 0) {
      uint256 pendingAmount = userReward - user.rewardDebt;
      s().rewardToken.transfer(_to, pendingAmount);
      s().paidOut += pendingAmount;
      emit Harvest(_to, pendingAmount);
    }
    user.rewardDebt = userReward;
  }
}
