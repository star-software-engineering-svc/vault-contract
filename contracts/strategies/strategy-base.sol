pragma solidity ^0.6.7;

import "../lib/erc20.sol";
import "../lib/safe-math.sol";

import "../interfaces/jar.sol";
import "../interfaces/master-belt.sol";
import "../interfaces/belt-lp.sol";
import "../interfaces/uniswapv2.sol";

// Strategy Contract Basics

abstract contract StrategyBase {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    // Performance Fee addresses and staking contract address
    address public initiator; // ETH Work
    address public owner = 0xC146C87c8E66719fa1E151d5A7D6dF9f0D3AD156; // ETH Work
    address public upbots = 0xC146C87c8E66719fa1E151d5A7D6dF9f0D3AD156; // ETH Work

    // Tokens
    address public want; // usdt
    address public lptoken;

    // User accounts
    address public jar;

    // Dex
    address public pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // mainnet v2
    // address public pancakeRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // testnet

    mapping(address => bool) whiteList;

    constructor(
        address _want,
        address _lptoken
    ) public {
        require(_want != address(0));
        require(_lptoken != address(0));

        initiator = msg.sender;
        whiteList[initiator] = true;
        whiteList[owner] = true;

        want = _want;
        lptoken = _lptoken;
    }

    // **** Views **** //

    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfLptoken() public view returns (uint256) {
        return IERC20(lptoken).balanceOf(address(this));
    }

    function balanceOfPool() internal virtual view returns (uint256);

    function calcBalanceFromLP() public virtual view returns (uint256);

    function getHarvestable() external virtual view returns (uint256);

    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(calcBalanceFromLP());
    }

    function getName() external virtual pure returns (string memory);

    // **** Setters **** //

    function setOwner(address _owner) external {
        require(msg.sender == initiator || msg.sender == owner, "Not owner");
        owner = _owner;
    }

    function setUpbots(address _upbots) external {
        require(msg.sender == initiator || msg.sender == owner, "Not owner");
        upbots = _upbots;
    }

    function setJar(address _jar) external {
        require(msg.sender == initiator || msg.sender == owner, "Not owner");
        jar = _jar;
    }

    // **** State mutations **** //
    function deposit() public virtual;

    // Jar only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint256 balance) {
        require(msg.sender == jar, "!jar");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(jar, balance);
    }

    // Withdraw partial funds, normally used with a jar withdrawal
    function withdraw(uint256 _amount) external {
        require(msg.sender == jar, "!jar");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        IERC20(want).safeTransfer(jar, _amount);
    }

    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);

    function harvest() public virtual;

    function _swapPancakeswapWithPath(
        address[] memory path,
        uint256 _amount
    ) internal {
        require(path[1] != address(0));

        // Swap with uniswap
        IERC20(path[0]).safeApprove(pancakeRouter, 0);
        IERC20(path[0]).safeApprove(pancakeRouter, _amount);

        UniswapRouterV2(pancakeRouter).swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            now.add(60)
        );
    }

    function addToWhiteList(address _address) public {
        require(msg.sender == initiator || msg.sender == owner, "Not owner");
        whiteList[_address] = true;
    }

    function removeFromWhiteList(address _address) public {
        require(msg.sender == initiator || msg.sender == owner, "Not owner");
        whiteList[_address] = false;
    }

    function isWhitelisted(address _address) public view returns(bool) {
        return whiteList[_address];
    }
}
