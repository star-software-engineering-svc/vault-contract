pragma solidity ^0.6.7;

import "./strategy-base.sol";

// Base contract for SNX Staking rewards contract interfaces

abstract contract StrategyStakingRewardsBase is StrategyBase {
    address public rewards;
    address public lp;

    uint256 private constant UNIT_LP_AMOUNT = 1000000;

    // **** Getters ****
    constructor(
        address _rewards,   // master belt
        address _lp,        // liquidity pool
        address _want,      // usdt
        address _lptoken    // lp token
    )
        public
        StrategyBase(_want, _lptoken)
    {
        rewards = _rewards;
        lp = _lp;
    }

    function balanceOfPool() internal override view returns (uint256) {
        return IMasterBelet(rewards).stakedWantTokens(3, address(this)); // pool id = 3
    }
    
    function calcBalanceFromLP() public override view returns (uint256) {

        uint256 _balanceOflptoken = balanceOfLptoken();
        uint256 _stakedAmount = balanceOfPool();

        return IBeltLP(lp).calc_withdraw_one_coin(_balanceOflptoken.add(_stakedAmount), 2); // token number (for usdt) = 2
    }

    function getHarvestable() external override view returns (uint256) {
        return IMasterBelet(rewards).pendingBELT(3, address(this));
    }

    // **** Setters ****

    function deposit() public override {
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            //add liquidity to 4belt
            IERC20(want).safeApprove(lp, 0);
            IERC20(want).safeApprove(lp, _want);
            uint256[4] memory uamounts = [0, 0, _want, 0];
            IBeltLP(lp).add_liquidity(uamounts, 0);


            uint256 _lptoken = IERC20(lptoken).balanceOf(address(this));
            // stake lptoken in 4belt
            IERC20(lptoken).safeApprove(rewards, 0);
            IERC20(lptoken).safeApprove(rewards, _lptoken);
            IMasterBelet(rewards).deposit(3, _lptoken);
        }
    }

    function _withdrawSome(uint256 _amount)
        internal
        override
        returns (uint256)
    {
        uint256 initialBalance = IERC20(want).balanceOf(address(this));
    
        uint256 _unitWantAmount = IBeltLP(lp).calc_withdraw_one_coin(UNIT_LP_AMOUNT, 2);
        uint256 _lpToUnstake = UNIT_LP_AMOUNT.mul(_amount).div(_unitWantAmount); // add exception logic
        
        IMasterBelet(rewards).withdraw(3, _lpToUnstake);

        // [remove liquidity]
        IERC20(lptoken).safeApprove(lp, 0);
        IERC20(lptoken).safeApprove(lp, _lpToUnstake);
        IBeltLP(lp).remove_liquidity_one_coin(_lpToUnstake, 2, 0);

        uint256 newBalance = IERC20(want).balanceOf(address(this));
        
        return newBalance.sub((initialBalance));
    }
}
