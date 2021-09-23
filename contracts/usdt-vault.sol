pragma solidity ^0.6.7;

import "./interfaces/strategy.sol";

import "./lib/erc20.sol";
import "./lib/safe-math.sol";

contract UsdtVault is Context {
    using Address for address;
    using SafeMath for uint256;

    address public UBXT = 0xBbEB90cFb6FAFa1F69AA130B7341089AbeEF5811; // mainnet ubxt
    // address public UBXT = 0xCf5641BA497aa5e7e6Da2f314af8054eB9BeFFf8; // testnet ubxt
    IERC20 public token;
    uint256 private constant magnitude = 10**24; //The magnitute of the entire token supply
    
    //Staking mappings
    //address[] internal stakeholders;
    mapping (address => uint256) private _stakedToken; // share per user
    mapping (address => uint256) private _accruedUBXT; // 
    mapping (address => uint256) private _stakeEntry; //S naught
    
    //Staking pool
    uint256 public _stakedTokenPool; // total share
    uint256 private _totalAccruedUBXT; //S
    uint256 private _actualAccruedUBXT; //UBXT that exists in the contract reward pool
    
    uint256 public min = 9500;
    uint256 public constant max = 10000;

    address public strategy;

    constructor(address _strategy) public
    {
        token = IERC20(IStrategy(_strategy).want());
        strategy = _strategy;
    }

    function depositAll() external {
        deposit(token.balanceOf(msg.sender));
    }

    function deposit(uint256 stakeAmount) public {
        
        require(token.balanceOf(msg.sender) >= stakeAmount, "Insufficient Token balance");
        
        uint256 initialTokenBalance = token.balanceOf(address(this));
        token.transferFrom(msg.sender, address(this), stakeAmount);
        uint256 newTokenBalance = token.balanceOf(address(this));
        
        uint256 tokenReceived = newTokenBalance.sub(initialTokenBalance);

        if(_stakedToken[msg.sender] == 0)
        {
            _stakeEntry[msg.sender] = _totalAccruedUBXT;
        }
        else
        {
            uint256 reward = _calculateReward(msg.sender);
            _accruedUBXT[msg.sender] = _accruedUBXT[msg.sender].add(reward);
            _stakeEntry[msg.sender] = _totalAccruedUBXT;
        }

        _stakedToken[msg.sender] = _stakedToken[msg.sender].add(tokenReceived);
        _stakedTokenPool = _stakedTokenPool.add(tokenReceived);

        _earn();
        
    }

    function withdrawAll() external {
        
        require(_stakedToken[msg.sender] > 0, "Message sender has no staked token");

        uint256 reward = _calculateReward(msg.sender);
        _accruedUBXT[msg.sender] = _accruedUBXT[msg.sender].add(reward);
        _stakeEntry[msg.sender] = _totalAccruedUBXT;
        
        // withdraw
        uint256 _before = token.balanceOf(address(this));
        uint256 _poolSize = IStrategy(strategy).balanceOf();
        uint256 _myPool = _poolSize.mul(_stakedToken[msg.sender]).div(_stakedTokenPool);
        IStrategy(strategy).withdraw(_myPool);
        uint256 _after = token.balanceOf(address(this));
        uint256 _amount = _after.sub(_before);
        if (_amount  > _myPool) {
            _amount = _myPool;
        }
        token.transfer(msg.sender, _amount);
        _stakedTokenPool = _stakedTokenPool.sub(_stakedToken[msg.sender]);
        _stakedToken[msg.sender] = 0;
    }

    function withdraw(uint256 unstakeAmount) public {
        
        require(unstakeAmount > 0, "Cannot unstake 0 Token");
        require(_stakedToken[msg.sender] >= unstakeAmount, "Insufficient staked Token");
        
        // claim reward
        uint256 reward = _calculateReward(msg.sender);
        _accruedUBXT[msg.sender] = _accruedUBXT[msg.sender].add(reward);
        _stakeEntry[msg.sender] = _totalAccruedUBXT;
        
        // withdraw
        uint256 _before = token.balanceOf(address(this));
        uint256 _poolSize = IStrategy(strategy).balanceOf();
        uint256 _myPool = _poolSize.mul(unstakeAmount).div(_stakedTokenPool);
        IStrategy(strategy).withdraw(_myPool);
        uint256 _after = token.balanceOf(address(this));
        uint256 _amount = _after.sub(_before);
        if (_amount  > _myPool) {
            _amount = _myPool;
        }
        token.transfer(msg.sender, _amount);
        _stakedToken[msg.sender] = _stakedToken[msg.sender].sub(unstakeAmount);
        _stakedTokenPool = _stakedTokenPool.sub(unstakeAmount);
    }

    function claimUBXT(uint256 amount) public
    {
        require(currentRewards(msg.sender) >= amount, "Insufficient accrued UBXT");
        
        uint256 reward = _calculateReward(msg.sender);
        _accruedUBXT[msg.sender] = _accruedUBXT[msg.sender].add(reward);
        _stakeEntry[msg.sender] = _totalAccruedUBXT;
        
        IERC20(UBXT).transfer(msg.sender, amount);
        _actualAccruedUBXT = _actualAccruedUBXT.sub(amount);
        _accruedUBXT[msg.sender] = _accruedUBXT[msg.sender].sub(amount);
    }
    
    function claimVaultUBXT() public
    {
        if(_stakedTokenPool != 0)
        {
            uint256 initialUBXTBalance = IERC20(UBXT).balanceOf(address(this));
            IStrategy(strategy).harvest();
            uint256 newUBXTBalance = IERC20(UBXT).balanceOf(address(this));

            uint256 amount = newUBXTBalance.sub(initialUBXTBalance);
            _actualAccruedUBXT = _actualAccruedUBXT.add(amount);
            _totalAccruedUBXT = _totalAccruedUBXT.add(amount.mul(magnitude).div(_stakedTokenPool));
        }
        else
        {
            return;
        }
    }
    
    function _earn() public {
        uint256 _bal = token.balanceOf(address(this));
        token.transfer(strategy, _bal);
        IStrategy(strategy).deposit();
    }

    function stakedTokens(address addy) public view returns (uint256)
    {
        return _stakedToken[addy];
    }
    
    function currentRewards(address addy) public view returns (uint256)
    {
        return _accruedUBXT[msg.sender].add(_calculateReward(addy));
    }
    
    function _calculateReward(address addy) private view returns (uint256)
    {
        return (_stakedToken[addy].mul(_totalAccruedUBXT.sub(_stakeEntry[addy]))).div(magnitude);
    }
    
}
