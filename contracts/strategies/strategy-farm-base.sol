// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "./strategy-staking-rewards-base.sol";

interface MisStaking {
    function notifyReward(uint256) external;
}

abstract contract StrategyFarmBase is StrategyStakingRewardsBase {
    // Token addresses
    address public belt = 0xE0e514c71282b6f4e823703a39374Cf58dc3eA4f; // mainnet
    // address public belt = 0x4d955CEF4009f8409558C9666D0237BE22FDd6C2; // testnet
    
    address public ubxt = 0xBbEB90cFb6FAFa1F69AA130B7341089AbeEF5811; // mainnet
    // address public ubxt = 0xCf5641BA497aa5e7e6Da2f314af8054eB9BeFFf8; // testnet

    address public wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    

    // 1% UBXT to upbots
    uint256 public upbotUBXT = 1;
    uint256 public burnUBXT = 10;
    uint256 public constant UBXTMax = 100;

    // Uniswap swap paths
    address[] public belt_ubxt_path;

    constructor(
        address _rewards,
        address _lp,
        address _want,
        address _lptoken
    )
        public
        StrategyStakingRewardsBase(
            _rewards,
            _lp,
            _want,
            _lptoken
        )
    {
        belt_ubxt_path = new address[](4);
        belt_ubxt_path[0] = belt;
        belt_ubxt_path[1] = wbnb;
        belt_ubxt_path[2] = busd;
        belt_ubxt_path[3] = ubxt;
    }

    // **** State Mutations ****

    function harvest() public override {
        
        require(isWhitelisted(msg.sender), "Not whitelisted");
        
        // get reward
        IMasterBelet(rewards).withdraw(3, 0);
        uint256 _belt = IERC20(belt).balanceOf(address(this));

        if (_belt > 0) {
            
            _swapPancakeswapWithPath(belt_ubxt_path, _belt);

            
            uint256 _ubxt = IERC20(ubxt).balanceOf(address(this));

            uint256 _upbotUBXT = _ubxt.mul(upbotUBXT).div(UBXTMax);
            uint256 _burnUBXT = _ubxt.mul(burnUBXT).div(UBXTMax);

            IERC20(ubxt).safeTransfer(
                upbots, // upbot
                _upbotUBXT
            );
            
            IERC20(ubxt).safeTransfer(
                address(0), // burn
                _burnUBXT
            );
            
            IERC20(ubxt).safeTransfer(
                jar, // vault
                _ubxt.sub(_upbotUBXT).sub(_burnUBXT)
            );
        }

    }
}
