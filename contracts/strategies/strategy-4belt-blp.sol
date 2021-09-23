pragma solidity ^0.6.7;

import "./strategy-farm-base.sol";

contract Strategy4BeltBlp is StrategyFarmBase {
    // Token addresses
    address public staking_pool = 0xD4BbC80b9B102b77B21A06cb77E954049605E6c1; // Master Belt mainnet
    // address public staking_pool = 0xaB6C91913E1ef4A9b58c85426F9ecF36EeBbF33f; // Master Belt testnet
    
    address public lp_pool = 0xF6e65B33370Ee6A49eB0dbCaA9f43839C1AC04d5; // Master Belt
    // address public lp_pool = 0x3CFbA6d803bee6b8ba06e1D4b7A54fE32d06b0b4; // Master Belt

    address public _4belt_blp = 0x9cb73F20164e399958261c289Eb5F9846f4D1404; // mainnet
    // address public _4belt_blp = 0xB2636d8907F37ef6f10F0cA4f558e2866F5797A2; // testnet


    address public usdt = 0x55d398326f99059fF775485246999027B3197955; // mainnet
    // address public usdt = 0x89ADeed6d6E0AeF67ad324e4F3424c8Af2F98dC2; // testnet
    

    constructor()
        public
        StrategyFarmBase(
            staking_pool,
            lp_pool,
            usdt,
            _4belt_blp
        )
    {
    }

    // **** Views ****

    function getName() external override pure returns (string memory) {
        return "Strategy4BeltBlp";
    }
}
