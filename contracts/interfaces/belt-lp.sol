// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface IBeltLP {
  function add_liquidity ( uint256[4] calldata uamounts, uint256 min_mint_amount ) external;
  function remove_liquidity ( uint256 _amount, uint256[] calldata min_uamounts ) external;
  function remove_liquidity_imbalance ( uint256[4] calldata uamounts, uint256 max_burn_amount ) external;
  function calc_withdraw_one_coin ( uint256 _token_amount, int128 i ) external view returns ( uint256 out );
  function remove_liquidity_one_coin ( uint256 _token_amount, int128 i, uint256 min_uamount ) external;
  function remove_liquidity_one_coin ( uint256 _token_amount, int128 i, uint256 min_uamount, bool donate_dust ) external;
  function withdraw_donated_dust (  ) external;
  function coins ( int128 arg0 ) external returns ( address out );
  function underlying_coins ( int128 arg0 ) external returns ( address out );
  function beltLP (  ) external returns ( address out );
  function token (  ) external returns ( address out );
}
