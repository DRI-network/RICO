pragma solidity ^0.4.18;
import "./RICO.sol";

/// @title SimpleICO - Sample ICO using with RICO Framework
/// @author - Yusaku Senga <senga@dri.network>
/// license let's see in LICENSE


contract Launcher {
  address public projectOwner;
  RICO public ico;
  string name = "Responsible ICO Token";
  string symbol = "RIT";
  uint8 decimals = 18;
  uint256 totalSupply = 400000 ether; // set maximum supply to 400,000.
  uint256 tobAmountToken = totalSupply * 2 / 100; // set token TOB ratio to 2% of total supply.
  uint256 tobAmountWei = 100 ether; // set ether TOB spent to 100 ether.
  uint256 PoDCapToken = totalSupply * 50 / 100; // set proof of donation token cap to 50% of Total Supply.
  uint256 PoDCapWei = 10000 ether; // set proof of donation ether cap to 10,000 ether.
  uint256 firstSupply = totalSupply * 30 / 100; // set first token supply to 30% of total supply.
  uint256 firstSupplyTime = block.timestamp + 40 days; // set first mintable time to 40 days.（after 40 days elapsed)
  uint256 secondSupply = totalSupply * 18 / 100; // set second token supply to 18% of total supply.
  uint256 secondSupplyTime = block.timestamp + 140 days; // set second mintable time to 140 days.（after 140 days elapsed)
  address mm_1 = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC; // set first market maker's address 
  uint256 mm_1_amount = 10 ether; // set ether amount to 100 ether for first market maker.
  uint256 mmCreateTime = block.timestamp + 100 days; // set ether transferable time to 100 days.
  uint256 PoDstrat = 0;      //set token strategy.


  function Launcher() public {
    projectOwner = msg.sender;
  }

  function init(address _rico) returns(bool) {
    require(msg.sender == projectOwner);
    ico = RICO(_rico);
    return true;
  }

  function setup() returns(bool) {
    require(msg.sender == projectOwner);
    ico.init(0x0, totalSupply, tobAmountToken, tobAmountWei, PoDCapToken, PoDCapWei, PoDstrat, projectOwner);
    ico.initTokenData(name, symbol, decimals);
    ico.addTokenRound(firstSupply, firstSupplyTime, projectOwner);
    ico.addTokenRound(secondSupply, secondSupplyTime, projectOwner);
    ico.addWithdrawalRound(mm_1_amount, mmCreateTime, mm_1, true);
    return true;
  }
}