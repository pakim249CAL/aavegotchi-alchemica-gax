// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.13;

import "./interfaces/IUniswapV2Factory.sol";
import "./UniswapV2Pair.sol";

contract UniswapV2Factory is IUniswapV2Factory {
  address public override feeTo;
  address public override feeToSetter;
  address public override migrator;
  uint256 public override mintFeeToDenominator;

  mapping(address => mapping(address => address))
    public
    override getPair;
  mapping(address => mapping(address => uint256))
    public
    override swapFee;
  address[] public override allPairs;

  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );
  event SwapFeeSet(
    address indexed token0,
    address indexed token1,
    uint256
  );
  event TradingFeeMintSet(uint256);

  constructor(address _feeToSetter) {
    feeToSetter = _feeToSetter;
  }

  function allPairsLength() external view override returns (uint256) {
    return allPairs.length;
  }

  function pairCodeHash() external pure returns (bytes32) {
    return keccak256(type(UniswapV2Pair).creationCode);
  }

  function createPair(address tokenA, address tokenB)
    external
    override
    returns (address pair)
  {
    require(msg.sender == feeToSetter);
    require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
    (address token0, address token1) = tokenA < tokenB
      ? (tokenA, tokenB)
      : (tokenB, tokenA);
    require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
    require(
      getPair[token0][token1] == address(0),
      "UniswapV2: PAIR_EXISTS"
    ); // single check is sufficient
    bytes memory bytecode = type(UniswapV2Pair).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(token0, token1));
    assembly {
      pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
    }
    UniswapV2Pair(pair).initialize(token0, token1);
    getPair[token0][token1] = pair;
    getPair[token1][token0] = pair; // populate mapping in the reverse direction
    allPairs.push(pair);
    emit PairCreated(token0, token1, pair, allPairs.length);
  }

  /** @dev Just a note for myself about this implementation that can be deleted later.
   * The desired goal is to be able to set swap fees per pair and support
   * different fees based on which direction the swap is in
   * Tokens in a pair are ordered by their address. This can make setting fees
   * very confusing. So we have the user input the buy and sell fees, and offload the work
   * of figuring out which order here. */
  function setPairFee(
    address tokenA,
    address tokenB,
    uint256 buyFee,
    uint256 sellFee
  ) external {
    require(msg.sender == feeToSetter);
    require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
    require(
      tokenA != address(0) && tokenB != address(0),
      "UniswapV2: ZERO_ADDRESS"
    );
    // Hard limiting the swap fee to 2% to add rug resistance
    require(buyFee < 20 && sellFee < 20, "GAX: FEE_TOO_HIGH");
    if (tokenA > tokenB) {
      (buyFee, sellFee) = (sellFee, buyFee);
    }
    swapFee[tokenA][tokenB] = buyFee;
    swapFee[tokenB][tokenA] = sellFee;
    emit SwapFeeSet(tokenA, tokenB, buyFee);
    emit SwapFeeSet(tokenB, tokenA, sellFee);
  }

  function setTradingFeeMint(uint256 denominator) external {
    require(msg.sender == feeToSetter);
    mintFeeToDenominator = denominator;
    emit TradingFeeMintSet(denominator);
  }

  function setFeeTo(address _feeTo) external override {
    require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
    feeTo = _feeTo;
  }

  function setMigrator(address _migrator) external override {
    require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
    migrator = _migrator;
  }

  function setFeeToSetter(address _feeToSetter) external override {
    require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
    feeToSetter = _feeToSetter;
  }
}
