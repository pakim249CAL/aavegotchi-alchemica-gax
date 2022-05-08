pragma solidity 0.8.13;

import "./TestSetupFarm.t.sol";

contract FarmTest is TestSetupFarm {
  function testInit() public {
    assertEq(farm.startBlock(), startBlock);
    assertEq(farm.endBlock(), startBlock);
    assertEq(address(farm.rewardToken()), address(rewardToken));
  }

  function testAdd(uint256 numTokens) public {
    vm.assume(numTokens > 0 && numTokens <= 20);
    uint256 totalAllocPoint;

    //Only owner check
    vm.prank(address(user1));
    vm.expectRevert("LibDiamond: Must be contract owner");
    farm.add(1, lpTokens[0], true);

    for (uint256 i = 0; i < numTokens; i++) {
      farm.add(i, lpTokens[i], true);
      totalAllocPoint += i;
    }
    assertEq(farm.totalAllocPoint(), totalAllocPoint);
    assertEq(farm.poolLength(), numTokens);
    for (uint256 i = 0; i < numTokens; i++) {
      PoolInfo memory poolInfo = farm.poolInfo(i);
      assertEq(address(poolInfo.lpToken), address(lpTokens[i]));
      assertEq(poolInfo.allocPoint, i);
      assertEq(poolInfo.lastRewardBlock, startBlock);
      assertEq(poolInfo.accERC20PerShare, 0);
    }

    vm.expectRevert("add: LP token already added");
    farm.add(1, lpTokens[0], true);
  }

  function testSet() public {
    farm.add(1, lpTokens[0], true);

    //Only owner check
    vm.prank(address(user1));
    vm.expectRevert("LibDiamond: Must be contract owner");
    farm.set(0, 10, true);

    farm.set(0, 10, true);
    assertEq(address(farm.poolInfo(0).lpToken), address(lpTokens[0]));
    assertEq(farm.poolInfo(0).allocPoint, 10);
    assertEq(farm.poolInfo(0).lastRewardBlock, startBlock);
    assertEq(farm.poolInfo(0).accERC20PerShare, 0);
  }

  // Testing for proper deposit amounts only
  // Harvest amounts tested in testHarvest
  function testDeposit(uint256 amount) public {
    vm.assume(amount > 0 && amount <= 1e50);

    rewardToken.mint(address(this), 1e20);
    rewardToken.approve(address(farm), 1e20);

    farm.add(1, lpTokens[0], true);

    vm.roll(startBlock + 10);

    lpTokens[0].mint(address(user1), amount);
    vm.prank(address(user1));
    lpTokens[0].approve(address(farm), amount);
    vm.prank(address(user1));
    farm.deposit(0, amount);

    farm.updatePool(0);

    vm.prank(address(user1));
    farm.deposit(0, 0);

    assertEq(farm.userInfo(0, address(user1)).amount, amount);
    assertEq(farm.userInfo(0, address(user1)).rewardDebt, 0);
  }

  function testWithdraw(uint256 amount) public {
    vm.assume(amount > 0 && amount <= 1e50);

    rewardToken.mint(address(this), 1e20);
    rewardToken.approve(address(farm), 1e20);

    farm.add(1, lpTokens[0], true);

    vm.roll(startBlock + 10);

    lpTokens[0].mint(address(user1), amount);
    vm.prank(address(user1));
    lpTokens[0].approve(address(farm), amount);
    vm.prank(address(user1));
    farm.deposit(0, amount);

    farm.updatePool(0);

    vm.prank(address(user1));
    farm.withdraw(0, amount);

    assertEq(farm.userInfo(0, address(user1)).amount, 0);
    assertEq(farm.userInfo(0, address(user1)).rewardDebt, 0);
    assertEq(lpTokens[0].balanceOf(address(user1)), amount);
    assertEq(lpTokens[0].balanceOf(address(farm)), 0);
  }

  function testPending(uint256 amount, uint8 numTokens) public {
    vm.assume(amount > 0 && amount <= 1e50);
    vm.assume(numTokens > 0 && numTokens <= 20);

    rewardToken.mint(address(this), 1e20);
    rewardToken.approve(address(farm), 1e20);

    vm.roll(startBlock);

    for (uint256 i = 0; i < numTokens; i++) {
      farm.add(1, lpTokens[i], true);
      lpTokens[i].mint(address(user1), amount);
      vm.prank(address(user1));
      lpTokens[i].approve(address(farm), amount);
      vm.prank(address(user1));
      farm.deposit(i, amount);
    }

    uint256 pending;
    for (uint256 i = 0; i < 100; i++) {
      vm.roll(block.number + i);
      for (uint256 j = 0; j < numTokens; j++) {
        assertGe(farm.pending(j, address(user1)), pending);
      }
    }
  }

  function testHarvest(
    uint256 amount,
    uint8 period,
    uint8 numTokens
  ) public {
    vm.assume(amount > 1 && amount <= 1e50);
    vm.assume(period > 0 && period < 200);
    vm.assume(numTokens > 0 && numTokens <= 5);

    rewardToken.mint(address(this), 1e20);
    rewardToken.approve(address(farm), 1e20);

    for (uint256 i = 0; i < numTokens; i++) {
      farm.add(1, lpTokens[i], true);
      lpTokens[i].mint(address(user1), amount);
      lpTokens[i].mint(address(user2), amount);

      vm.prank(address(user1));
      lpTokens[i].approve(address(farm), amount);
      vm.prank(address(user1));
      farm.deposit(i, amount);

      vm.prank(address(user2));
      lpTokens[i].approve(address(farm), amount);
      vm.prank(address(user2));
      farm.deposit(i, amount);
    }

    vm.roll(startBlock + period);

    for (uint256 i = 0; i < numTokens; i++) {
      uint256 pending = farm.pending(i, address(user1));
      vm.prank(address(user1));
      farm.harvest(i);
      vm.prank(address(user2));
      farm.harvest(i);
      assertEq(farm.userInfo(i, address(user1)).amount, amount, "1");
      assertEq(
        pending,
        farm.userInfo(i, address(user1)).rewardDebt,
        "2"
      );
    }
  }

  function testEmergencyWithdraw(uint256 amount, uint8 numTokens)
    public
  {
    vm.assume(amount > 0 && amount <= 1e50);
    vm.assume(numTokens > 0 && numTokens <= 20);

    rewardToken.mint(address(this), 1e20);
    rewardToken.approve(address(farm), 1e20);

    for (uint256 i = 0; i < numTokens; i++) {
      farm.add(1, lpTokens[i], true);
      lpTokens[i].mint(address(user1), amount);
      vm.prank(address(user1));
      lpTokens[i].approve(address(farm), amount);
      vm.prank(address(user1));
      farm.deposit(i, amount);
    }

    for (uint256 i = 0; i < numTokens; i++) {
      vm.prank(address(user1));
      farm.emergencyWithdraw(i);
      assertEq(farm.userInfo(i, address(user1)).amount, 0);
      assertEq(farm.userInfo(i, address(user1)).rewardDebt, 0);
      assertEq(lpTokens[i].balanceOf(address(user1)), amount);
    }
  }
}
