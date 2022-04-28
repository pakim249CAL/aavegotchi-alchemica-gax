// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../libraries/LibFarm.sol";
import "../abstract/ReentrancyGuard.sol";
import "../abstract/Ownable.sol";

contract FarmFacet is Ownable, ReentrancyGuard {
  // Fund the farm, increase the end block
  function fund(uint256 _amount) external onlyOwner {
    LibFarm.fund(_amount);
  }

  // Add a new lp to the pool. Can only be called by the owner.
  // DO NOT add the same LP token more than once. Rewards will be messed up if you do.
  function add(
    uint256 _allocPoint,
    IERC20 _lpToken,
    bool _withUpdate
  ) external onlyOwner {
    LibFarm.add(_allocPoint, _lpToken, _withUpdate);
  }

  // Update the given pool's ERC20 allocation point. Can only be called by the owner.
  function set(
    uint256 _pid,
    uint256 _allocPoint,
    bool _withUpdate
  ) external onlyOwner {
    LibFarm.set(_pid, _allocPoint, _withUpdate);
  }

  // Update reward variables for all pools. Be careful of gas spending!
  function massUpdatePools() external {
    LibFarm.massUpdatePools();
  }

  // Update reward variables of the given pool to be up-to-date.
  function updatePool(uint256 _pid) external {
    LibFarm.updatePool(_pid);
  }

  // Deposit LP tokens to Farm for ERC20 allocation.
  function deposit(uint256 _pid, uint256 _amount)
    external
    nonReentrant
  {
    LibFarm.deposit(_pid, _amount);
  }

  // Withdraw LP tokens from Farm.
  function withdraw(uint256 _pid, uint256 _amount)
    external
    nonReentrant
  {
    LibFarm.withdraw(_pid, _amount);
  }

  // Harvest rewards
  function harvest(uint256 _pid) external nonReentrant {
    LibFarm.updatePoolAndHarvest(msg.sender, _pid);
  }

  // Batch harvest rewards
  function batchHarvest(uint256[] memory _pids)
    external
    nonReentrant
  {
    for (uint256 i = 0; i < _pids.length; ++i) {
      LibFarm.updatePoolAndHarvest(msg.sender, _pids[i]);
    }
  }

  // Withdraw without caring about rewards. EMERGENCY ONLY.
  function emergencyWithdraw(uint256 _pid) external nonReentrant {
    LibFarm.emergencyWithdraw(_pid);
  }

  //////////////////////////////////////////////////////////////////////////////
  // GETTERS
  //////////////////////////////////////////////////////////////////////////////

  // Storage pointer helper
  function s() private pure returns (FarmStorage.Layout storage fs) {
    return FarmStorage.layout();
  }

  // Number of LP pools
  function poolLength() external view returns (uint256) {
    return s().poolInfo.length;
  }

  // View function to see deposited LP for a user.
  function deposited(uint256 _pid, address _user)
    external
    view
    returns (uint256)
  {
    return s().userInfo[_pid][_user].amount;
  }

  // View function to see pending ERC20s for a user.
  function pending(uint256 _pid, address _user)
    external
    view
    returns (uint256)
  {
    PoolInfo storage pool = s().poolInfo[_pid];
    UserInfo storage user = s().userInfo[_pid][_user];
    uint256 accERC20PerShare = pool.accERC20PerShare;
    uint256 lpSupply = pool.lpToken.balanceOf(address(this));

    if (block.number > pool.lastRewardBlock && lpSupply != 0) {
      uint256 lastBlock = block.number < s().endBlock
        ? block.number
        : s().endBlock;
      uint256 nrOfBlocks = lastBlock - pool.lastRewardBlock;
      uint256 erc20Reward = (nrOfBlocks *
        s().rewardPerBlock *
        pool.allocPoint) / s().totalAllocPoint;
      accERC20PerShare =
        ((accERC20PerShare + erc20Reward) * 1e12) /
        lpSupply;
    }

    return (user.amount * accERC20PerShare) / 1e12 - user.rewardDebt;
  }

  // View function for total reward the farm has yet to pay out.
  function totalPending() external view returns (uint256) {
    if (block.number <= s().startBlock) {
      return 0;
    }

    uint256 lastBlock = block.number < s().endBlock
      ? block.number
      : s().endBlock;
    return
      s().rewardPerBlock * (lastBlock - s().startBlock) - s().paidOut;
  }

  function status() external view returns (uint256) {
    return s().status;
  }

  function rewardToken() external view returns (IERC20) {
    return s().rewardToken;
  }

  function paidOut() external view returns (uint256) {
    return s().paidOut;
  }

  function rewardPerBlock() external view returns (uint256) {
    return s().rewardPerBlock;
  }

  function poolInfo(uint256 _pid)
    external
    view
    returns (PoolInfo memory pi)
  {
    return s().poolInfo[_pid];
  }

  function poolTokens(address _token) external view returns (bool) {
    return s().poolTokens[_token];
  }

  function userInfo(uint256 _pid, address _user)
    external
    view
    returns (UserInfo memory ui)
  {
    return s().userInfo[_pid][_user];
  }

  function totalAllocPoint() external view returns (uint256) {
    return s().totalAllocPoint;
  }

  function startBlock() external view returns (uint256) {
    return s().startBlock;
  }

  function endBlock() external view returns (uint256) {
    return s().endBlock;
  }
}
