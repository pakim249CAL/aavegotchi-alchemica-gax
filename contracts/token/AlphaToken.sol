// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "./ERC20Capped.sol";

contract AlphaToken is Ownable, Initializable, ERC20Capped, ERC20Permit{
  //@todo: auto-approve installationDiamond to spend

  /** @dev This token is designed to be used behind a proxy. 
    * Because the permit typehash is set on construction,
    * it is important to never use the same implementation
    * contract for multiple tokens. Otherwise, permits can be double spent
    * across all tokens that use the same typehash. */
  constructor() ERC20("Gotchiverse ALPHA", "ALPHA") ERC20Permit("Gotchiverse ALPHA") {
  }

  function initialize(
    uint256 _maxSupply,
    address _realmDiamond,
    address _gameplayVestingContract,
    address _ecosystemVestingContract
  ) public initializer {
    ERC20Capped.initialize(_maxSupply);
    _mint(_gameplayVestingContract, _maxSupply / 10);
    _mint(_ecosystemVestingContract, _maxSupply / 10);
    transferOwnership(_realmDiamond);
  }

  /// @notice Mint _value tokens for msg.sender
  /// @param _value Amount of tokens to mint
  function mint(address _to, uint256 _value) public onlyOwner {
    _mint(_to, _value);
  }

  function _mint(address account, uint256 amount) internal virtual override(ERC20, ERC20Capped) {
      ERC20Capped._mint(account, amount);
  }

}
