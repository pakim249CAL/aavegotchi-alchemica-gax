// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@contracts/token/GAXLiquidityTokenReward.sol";
import "@contracts/diamond/facets/DiamondCutFacet.sol";
import "@contracts/diamond/facets/DiamondLoupeFacet.sol";
import "@contracts/diamond/facets/OwnershipFacet.sol";

import "@contracts/diamond/interfaces/IDiamondCut.sol";
import "@contracts/diamond/interfaces/IDiamondLoupe.sol";

import "@contracts/diamond/Diamond.sol";

import "@contracts/facets/FarmFacet.sol";
import "@contracts/init/FarmInit.sol";
import "@contracts/init/ReentrancyGuardInit.sol";

/** Helper farm diamond deployment contract. Facet and init contracts must already be deployed because of the contract size limit. */
contract FarmAndGLTRDeployer {
  struct DeployedAddresses {
    address diamondCutFacet;
    address diamondLoupeFacet;
    address ownershipFacet;
    address farmFacet;
    address farmInit;
    address reentrancyGuardInit;
  }

  struct FarmInitParams {
    uint256 rewardPerBlock;
    uint256 startBlock;
    uint256 endBlock;
    uint256 decayPeriod;
    uint256 decay;
  }

  function deployFarmAndGLTR(
    DeployedAddresses memory deployedAddresses,
    FarmInitParams memory farmInitParams
  ) public {
    IDiamondCut.FacetCut[] memory diamondCuts;
    IDiamondCut.FacetCut[] memory farmCuts;

    // Deploy GLTR and farm diamond
    GAXLiquidityTokenReward rewardToken = new GAXLiquidityTokenReward();
    Diamond diamond = new Diamond(
      address(this),
      deployedAddresses.diamondCutFacet
    );

    // Populate the diamond cuts with function selectors and facet addresses
    diamondCuts = populateDiamondCuts(
      deployedAddresses.diamondLoupeFacet,
      deployedAddresses.ownershipFacet
    );
    farmCuts = populateFarmCuts(deployedAddresses.farmFacet);

    // Cut diamond with diamond selectors and initialize reentry guard
    IDiamondCut(address(diamond)).diamondCut(
      diamondCuts,
      deployedAddresses.reentrancyGuardInit,
      abi.encodeWithSelector(ReentrancyGuardInit.init.selector)
    );

    // Cut diamond with farm selectors and initialize farm
    IDiamondCut(address(diamond)).diamondCut(
      farmCuts,
      deployedAddresses.farmInit,
      abi.encodeWithSelector(
        FarmInit.init.selector,
        address(rewardToken),
        farmInitParams.rewardPerBlock,
        farmInitParams.startBlock,
        farmInitParams.endBlock,
        farmInitParams.decayPeriod,
        farmInitParams.decay
      )
    );

    // Transfer all of the reward tokens to the farm diamond
    rewardToken.transfer(
      address(diamond),
      rewardToken.balanceOf(address(this))
    );

    // Transfer ownership of the diamond to the sender
    OwnershipFacet(address(diamond)).transferOwnership(msg.sender);
  }

  function populateDiamondCuts(
    address diamondLoupeFacet,
    address ownershipFacet
  )
    internal
    pure
    returns (IDiamondCut.FacetCut[] memory diamondCuts)
  {
    bytes4[] memory loupeFunctionSelectors = new bytes4[](4);
    {
      uint256 index;
      loupeFunctionSelectors[index++] = DiamondLoupeFacet
        .facets
        .selector;
      loupeFunctionSelectors[index++] = DiamondLoupeFacet
        .facetFunctionSelectors
        .selector;
      loupeFunctionSelectors[index++] = DiamondLoupeFacet
        .facetAddresses
        .selector;
      loupeFunctionSelectors[index++] = DiamondLoupeFacet
        .facetAddress
        .selector;
    }
    diamondCuts[0] = IDiamondCut.FacetCut(
      diamondLoupeFacet,
      IDiamondCut.FacetCutAction.Add,
      loupeFunctionSelectors
    );
    bytes4[] memory ownershipFunctionSelectors = new bytes4[](2);
    {
      uint256 index;
      ownershipFunctionSelectors[index++] = OwnershipFacet
        .owner
        .selector;
      ownershipFunctionSelectors[index++] = OwnershipFacet
        .transferOwnership
        .selector;
    }
    diamondCuts[1] = IDiamondCut.FacetCut(
      ownershipFacet,
      IDiamondCut.FacetCutAction.Add,
      ownershipFunctionSelectors
    );
    return diamondCuts;
  }

  function populateFarmCuts(address farmFacet)
    internal
    pure
    returns (IDiamondCut.FacetCut[] memory farmCuts)
  {
    bytes4[] memory farmFunctionSelectors = new bytes4[](23);
    {
      uint256 index;
      farmFunctionSelectors[index++] = FarmFacet.add.selector;
      farmFunctionSelectors[index++] = FarmFacet.set.selector;
      farmFunctionSelectors[index++] = FarmFacet
        .massUpdatePools
        .selector;
      farmFunctionSelectors[index++] = FarmFacet.updatePool.selector;
      farmFunctionSelectors[index++] = FarmFacet.deposit.selector;
      farmFunctionSelectors[index++] = FarmFacet.withdraw.selector;
      farmFunctionSelectors[index++] = FarmFacet.harvest.selector;
      farmFunctionSelectors[index++] = FarmFacet
        .batchHarvest
        .selector;
      farmFunctionSelectors[index++] = FarmFacet
        .emergencyWithdraw
        .selector;
      farmFunctionSelectors[index++] = FarmFacet.poolLength.selector;
      farmFunctionSelectors[index++] = FarmFacet.deposited.selector;
      farmFunctionSelectors[index++] = FarmFacet.pending.selector;
      farmFunctionSelectors[index++] = FarmFacet
        .totalPending
        .selector;
      farmFunctionSelectors[index++] = FarmFacet.rewardToken.selector;
      farmFunctionSelectors[index++] = FarmFacet.paidOut.selector;
      farmFunctionSelectors[index++] = FarmFacet
        .rewardPerBlock
        .selector;
      farmFunctionSelectors[index++] = FarmFacet.poolInfo.selector;
      farmFunctionSelectors[index++] = FarmFacet.poolTokens.selector;
      farmFunctionSelectors[index++] = FarmFacet.userInfo.selector;
      farmFunctionSelectors[index++] = FarmFacet
        .totalAllocPoint
        .selector;
      farmFunctionSelectors[index++] = FarmFacet.startBlock.selector;
      farmFunctionSelectors[index++] = FarmFacet.endBlock.selector;
    }
    farmCuts[0] = IDiamondCut.FacetCut(
      farmFacet,
      IDiamondCut.FacetCutAction.Add,
      farmFunctionSelectors
    );
  }
}
