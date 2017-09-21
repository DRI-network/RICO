pragma solidity ^0.4.15;
import "./RICO.sol";

/// @title SampleICO - SampleICO using with RICO Framework
/// @author - Yusaku Senga < syrohei@gmail.com >

contract SampleICO is RICO {

  string public name = "sample ico token";

  string public symbol = "sit";

  uint8 public decimals = 18;

  uint256 public totalSupply = 400000 ether;

  uint256 public tobAmountToken = totalSupply * 1 / 100;
  uint256 public proofOfDonationCap = totalSupply * 20 / 100;
  uint256 public secondSupply = totalSupply * 10 / 100;
  uint256 public thirdSupply = totalSupply * 69 / 100;

  uint256 public tobAmountWei = 100 ether;
  uint256 public proofOfDonationCapOfWei = 10000 ether;

  address public marketM_1 = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC;
  uint256 public merketM_amount = 100 ether;


  function SampleICO() { } 

  function init(address _projectOwner) external onlyOwner() returns (bool) {
     
     init(totalSupply, tobAmountToken, tobAmountWei, proofOfDonationCap, proofOfDonationCapOfWei, _projectOwner);    // tob 100 eth = 1 token

     initTokenData(name, symbol, decimals);

     uint256 secondSupplyTime = block.timestamp + 40 days;

     addRound(secondSupply, secondSupplyTime, _projectOwner);

     uint256 thirdSupplyTime = block.timestamp + 180 days;

     addRound(thirdSupply, thirdSupplyTime, _projectOwner);

     uint256 mmCreateTime = block.timestamp + 100 days;

     addMarketMaker(merketM_amount, mmCreateTime, marketM_1, "YUSAKU SENGA");

     return true;

  }
}
  