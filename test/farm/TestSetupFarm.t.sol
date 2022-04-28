pragma solidity 0.8.13;

import "forge-std/Test.sol";

import "@contracts/diamond/facets/DiamondCutFacet.sol";
import "@contracts/diamond/facets/DiamondLoupeFacet.sol";
import "@contracts/diamond/facets/OwnershipFacet.sol";

import "@contracts/diamond/interfaces/IDiamondCut.sol";
import "@contracts/diamond/interfaces/IDiamondLoupe.sol";

import "@contracts/diamond/Diamond.sol";

import "@contracts/facets/FarmFacet.sol";
import "@contracts/init/FarmInit.sol";

import "@contracts/test/Token.sol";

import "./helpers/FarmUser.sol";

contract TestSetupFarm is Test {
  Diamond diamond;
  DiamondCutFacet diamondCutFacet;
  DiamondLoupeFacet diamondLoupeFacet;
  OwnershipFacet ownershipFacet;

  FarmFacet farmFacet;
  FarmFacet farm;

  IDiamondCut.FacetCut[] diamondCuts;
  IDiamondCut.FacetCut[] farmCuts;

  FarmInit farmInit;

  Token[] lpTokens;
  Token rewardToken;

  FarmUser user1;
  FarmUser user2;

  uint256 startBlock;

  function setUp() public {
    deployAll();
    populateAndCut();
    populateUsers();
    farm = FarmFacet(address(diamond));
  }

  function deployAll() internal {
    deployDiamond();
    deployFarm();
    deployTokens(20);
  }

  function populateAndCut() internal {
    populateDiamondCuts();
    populateFarmCuts();
    IDiamondCut(address(diamond)).diamondCut(
      diamondCuts,
      address(0),
      ""
    );
    startBlock = block.number + 100;
    IDiamondCut(address(diamond)).diamondCut(
      farmCuts,
      address(farmInit),
      abi.encodeWithSelector(
        farmInit.init.selector,
        address(rewardToken),
        1e18,
        startBlock
      )
    );
  }

  function deployDiamond() internal {
    diamondCutFacet = new DiamondCutFacet();
    diamondLoupeFacet = new DiamondLoupeFacet();
    ownershipFacet = new OwnershipFacet();
    diamond = new Diamond(address(this), address(diamondCutFacet));
  }

  function deployFarm() internal {
    farmInit = new FarmInit();
    farmFacet = new FarmFacet();
  }

  function deployTokens(uint256 amount) internal {
    for (uint256 i = 0; i < amount; i++) {
      lpTokens.push(new Token());
    }
    rewardToken = new Token();
  }

  function populateDiamondCuts() internal {
    bytes4[] memory loupeFunctionSelectors = new bytes4[](4);
    {
      uint256 index;
      loupeFunctionSelectors[index++] = diamondLoupeFacet
        .facets
        .selector;
      loupeFunctionSelectors[index++] = diamondLoupeFacet
        .facetFunctionSelectors
        .selector;
      loupeFunctionSelectors[index++] = diamondLoupeFacet
        .facetAddresses
        .selector;
      loupeFunctionSelectors[index++] = diamondLoupeFacet
        .facetAddress
        .selector;
    }
    diamondCuts.push(
      IDiamondCut.FacetCut(
        address(diamondLoupeFacet),
        IDiamondCut.FacetCutAction.Add,
        loupeFunctionSelectors
      )
    );
    bytes4[] memory ownershipFunctionSelectors = new bytes4[](2);
    {
      uint256 index;
      ownershipFunctionSelectors[index++] = ownershipFacet
        .owner
        .selector;
      ownershipFunctionSelectors[index++] = ownershipFacet
        .transferOwnership
        .selector;
    }
    diamondCuts.push(
      IDiamondCut.FacetCut(
        address(ownershipFacet),
        IDiamondCut.FacetCutAction.Add,
        ownershipFunctionSelectors
      )
    );
  }

  function populateFarmCuts() internal {
    bytes4[] memory farmFunctionSelectors = new bytes4[](24);
    {
      uint256 index;
      farmFunctionSelectors[index++] = farmFacet.fund.selector;
      farmFunctionSelectors[index++] = farmFacet.add.selector;
      farmFunctionSelectors[index++] = farmFacet.set.selector;
      farmFunctionSelectors[index++] = farmFacet
        .massUpdatePools
        .selector;
      farmFunctionSelectors[index++] = farmFacet.updatePool.selector;
      farmFunctionSelectors[index++] = farmFacet.deposit.selector;
      farmFunctionSelectors[index++] = farmFacet.withdraw.selector;
      farmFunctionSelectors[index++] = farmFacet.harvest.selector;
      farmFunctionSelectors[index++] = farmFacet
        .batchHarvest
        .selector;
      farmFunctionSelectors[index++] = farmFacet
        .emergencyWithdraw
        .selector;
      farmFunctionSelectors[index++] = farmFacet.poolLength.selector;
      farmFunctionSelectors[index++] = farmFacet.deposited.selector;
      farmFunctionSelectors[index++] = farmFacet.pending.selector;
      farmFunctionSelectors[index++] = farmFacet
        .totalPending
        .selector;
      farmFunctionSelectors[index++] = farmFacet.status.selector;
      farmFunctionSelectors[index++] = farmFacet.rewardToken.selector;
      farmFunctionSelectors[index++] = farmFacet.paidOut.selector;
      farmFunctionSelectors[index++] = farmFacet
        .rewardPerBlock
        .selector;
      farmFunctionSelectors[index++] = farmFacet.poolInfo.selector;
      farmFunctionSelectors[index++] = farmFacet.poolTokens.selector;
      farmFunctionSelectors[index++] = farmFacet.userInfo.selector;
      farmFunctionSelectors[index++] = farmFacet
        .totalAllocPoint
        .selector;
      farmFunctionSelectors[index++] = farmFacet.startBlock.selector;
      farmFunctionSelectors[index++] = farmFacet.endBlock.selector;
    }
    farmCuts.push(
      IDiamondCut.FacetCut(
        address(farmFacet),
        IDiamondCut.FacetCutAction.Add,
        farmFunctionSelectors
      )
    );
  }

  function populateUsers() internal {
    user1 = new FarmUser();
    user2 = new FarmUser();
  }
}
