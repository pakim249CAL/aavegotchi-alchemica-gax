// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";

contract AlchemicaToken is OwnableUpgradeable, ERC20CappedUpgradeable, ERC20PermitUpgradeable {
  //@todo: auto-approve installationDiamond to spend

  function initialize(
    string calldata name,
    string calldata symbol,
    uint256 _maxSupply,
    address _realmDiamond,
    address _gameplayVestingContract,
    address _ecosystemVestingContract
  ) public initializer {
    __Ownable_init();
    __ERC20_init(name, symbol);
    __ERC20Capped_init(_maxSupply);
    __ERC20Permit_init(name);
    transferOwnership(_realmDiamond);
    _mint(_gameplayVestingContract, _maxSupply / 10);
    _mint(_ecosystemVestingContract, _maxSupply / 10);
  }

  /// @notice Mint _value tokens for msg.sender
  /// @param _value Amount of tokens to mint
  function mint(address _to, uint256 _value) public onlyOwner {
    _mint(_to, _value);
  }

  function _mint(address _to, uint256 _value) internal virtual override(
    ERC20CappedUpgradeable, 
    ERC20Upgradeable
  ) {
    ERC20CappedUpgradeable._mint(_to, _value);
  }

}
