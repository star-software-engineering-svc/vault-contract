// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface IMasterBelet {
  function BELT (  ) external view returns ( address );
  function BELTPerBlock (  ) external view returns ( uint256 );
  function add ( uint256 _allocPoint, address _want, bool _withUpdate, address _strat ) external;
  function burnAddress (  ) external view returns ( address );
  function deposit ( uint256 _pid, uint256 _wantAmt ) external;
  function emergencyWithdraw ( uint256 _pid ) external;
  function getMultiplier ( uint256 _from, uint256 _to ) external view returns ( uint256 );
  function inCaseTokensGetStuck ( address _token, uint256 _amount ) external;
  function massUpdatePools (  ) external;
  function owner (  ) external view returns ( address );
  function ownerBELTReward (  ) external view returns ( uint256 );
  function pendingBELT ( uint256 _pid, address _user ) external view returns ( uint256 );
  function poolInfo ( uint256 ) external view returns ( address want, uint256 allocPoint, uint256 lastRewardBlock, uint256 accBELTPerShare, address strat );
  function poolLength (  ) external view returns ( uint256 );
  function renounceOwnership (  ) external;
  function set ( uint256 _pid, uint256 _allocPoint, bool _withUpdate ) external;
  function stakedWantTokens ( uint256 _pid, address _user ) external view returns ( uint256 );
  function startBlock (  ) external view returns ( uint256 );
  function totalAllocPoint (  ) external view returns ( uint256 );
  function transferOwnership ( address newOwner ) external;
  function updatePool ( uint256 _pid ) external;
  function userInfo ( uint256, address ) external view returns ( uint256 shares, uint256 rewardDebt );
  function withdraw ( uint256 _pid, uint256 _wantAmt ) external;
  function withdrawAll ( uint256 _pid ) external;
}
