// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface IStrategy {
    function rewards() external view returns (address);

    function gauge() external view returns (address);

    function want() external view returns (address);

    function initiator() external view returns (address);

    function treasury() external view returns (address);

    function deposit() external;

    function withdraw(address) external;

    function withdraw(uint256) external;

    function skim() external;

    function balanceOf() external view returns (uint256);

    function getHarvestable() external view returns (uint256);

    function harvest() external;

    function setJar(address _jar) external;
    
    function setInitiator(address _initiator) external;

    function isWhitelisted(address _address) external view returns(bool);

    function addToWhiteList(address _address) external;

    function removeFromWhiteList(address _address) external;

    function execute(address _target, bytes calldata _data)
        external
        payable
        returns (bytes memory response);

    function execute(bytes calldata _data)
        external
        payable
        returns (bytes memory response);
}
