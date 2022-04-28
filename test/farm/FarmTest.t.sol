pragma solidity 0.8.13;

import "./TestSetupFarm.t.sol";

contract FarmTest is TestSetupFarm {
  function testInit() public {
    assertEq(farm.rewardPerBlock(), 1e18);
    assertEq(farm.startBlock(), startBlock);
    assertEq(farm.endBlock(), startBlock);
    assertEq(address(farm.rewardToken()), address(rewardToken));
  }

  function testFund(uint256 amount) public {
    vm.assume(amount > 0 && amount <= 1e50);

    rewardToken.mint(address(this), amount);
    rewardToken.approve(address(farm), amount);
    assertEq(rewardToken.balanceOf(address(this)), amount);

    //Only owner check
    vm.prank(address(user1));
    vm.expectRevert("LibDiamond: Must be contract owner");
    farm.fund(amount);

    farm.fund(amount);
    assertEq(rewardToken.balanceOf(address(this)), 0);
    assertEq(rewardToken.balanceOf(address(farm)), amount);
    assertEq(
      farm.endBlock(),
      startBlock + (amount / farm.rewardPerBlock())
    );
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
    for (uint256 i = 0; i < numTokens; i++) {
      PoolInfo memory poolInfo = farm.poolInfo(i);
      assertEq(address(poolInfo.lpToken), address(lpTokens[i]));
      assertEq(poolInfo.allocPoint, i);
      assertEq(poolInfo.lastRewardBlock, startBlock);
      assertEq(poolInfo.accERC20PerShare, 0);
    }
  }
}
