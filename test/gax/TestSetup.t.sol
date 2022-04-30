pragma solidity 0.8.13;

import "forge-std/Test.sol";

import "@contracts/uniswapv2/UniswapV2Factory.sol";
import "@contracts/uniswapv2/UniswapV2Router01.sol";

import "@contracts/uniswapv2/interfaces/IUniswapV2Factory.sol";
import "@contracts/uniswapv2/interfaces/IUniswapV2Router01.sol";
import "@contracts/uniswapv2/interfaces/IUniswapV2Pair.sol";
import "@contracts/uniswapv2/interfaces/IUniswapV2ERC20.sol";

import "@contracts/test/Token.sol";

contract TestSetup is Test {
  IUniswapV2Factory factory;
  IUniswapV2Router01 router;

  IUniswapV2Pair pair1;
  IUniswapV2Pair pair2;

  Token token1;
  Token token2;
  Token token3;

  function setUp() public {
    UniswapV2Factory _factory = new UniswapV2Factory(address(this));
    UniswapV2Router01 _router = new UniswapV2Router01(
      address(_factory),
      0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270
    );

    factory = IUniswapV2Factory(address(_factory));
    router = IUniswapV2Router01(address(_router));

    token1 = new Token();
    token2 = new Token();
    token3 = new Token();

    factory.createPair(address(token1), address(token2));
    factory.createPair(address(token1), address(token3));
    factory.createPair(address(token2), address(token3));
  }
}
