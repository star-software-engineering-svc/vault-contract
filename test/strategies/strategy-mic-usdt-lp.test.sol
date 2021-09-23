pragma solidity ^0.6.7;

import "../lib/test-strategy-farm-base.sol";

import "../../interfaces/strategy.sol";
import "../../interfaces/uniswapv2.sol";

import "../../dai-jar.sol";
import "../../strategies/strategy-dai.sol";

contract StrategyDaiTest is StrategyFarmTestBase {
    function setUp() public {
        want = 0x1af3f329e8be154074d8769d1ffa4ee058b1dbc3; // !!! updated (BSC)

        strategist = address(this);

        strategy = IStrategy(
            address(
                new StrategyMicUsdtLp(strategist)
            )
        );

        daiJar = new DaiJar(strategy);

        strategy.setJar(address(daiJar));
        strategy.addToWhiteList(strategist);

        // Set time
        hevm.warp(startTime);
    }

    // **** Tests ****

    function test_dai_withdraw_release() public {
        _test_withdraw_release();
    }

    function test_dai_get_earn_harvest_rewards() public {
        _test_get_earn_harvest_rewards();
    }
}
