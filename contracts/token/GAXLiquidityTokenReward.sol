// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract GAXLiquidityTokenReward is ERC20Permit {
  constructor()
    ERC20("FAKE GAX Liquidity Token Reward", "FGLTR")
    ERC20Permit("FAKE GAX Liquidity Token Reward")
  {
    _mint(msg.sender, 1e12 * 1e18); // 1 trillion
  }

  /// @notice Sends tokens mistakenly sent to this contract to the Aavegotchi DAO treasury
  function recoverERC20(address _token, uint256 _value)
    external
    virtual
  {
    ERC20(_token).transfer(
      0x6fb7e0AAFBa16396Ad6c1046027717bcA25F821f,
      _value
    );
  }
}
