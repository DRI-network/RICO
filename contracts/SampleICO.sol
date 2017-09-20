/**
 * @title SafeMath from https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 * @dev Math operations with safety checks that throw on error
 */
pragma solidity ^0.4.15;
import "./RICO.sol";


contract SampleICO is RICO {

  string public name = "sample ico token";

  string public symbol = "sit";

  uint8 public decimals = 18;

  uint256 public totalSupply = 400000 ether;

  uint256 public tobAmount = totalSupply * 1 / 100;

  uint256 public proofOfDonationCap = totalSupply * 20 / 100;

  uint256 public proofOfDonationCapOfWei = 10000 ether;

  uint256 public secondSupply = totalSupply * 10 / 100;

  uint256 public thirdSupply = totalSupply * 69 / 100;

  address public marketM_1 = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC;

  uint256 public merketM_amount = 100 ether;


  function SampleICO() { } 

  function init(address po) external onlyOwner() returns (bool) {
     
     init(totalSupply, po, tobAmount, 1);    // price 1 eth = 1 token

     initTokenData(name, symbol, decimals);

     uint256 secondSupplyTime = block.timestamp + 40 days;

     addRound(secondSupply, secondSupplyTime, po);

     uint256 thirdSupplyTime = block.timestamp + 180 days;

     addRound(thirdSupply, thirdSupplyTime, po);

     uint256 mmCreateTime = block.timestamp + 100 days;

     addMarketMaker(merketM_amount,mmCreateTime, marketM_1, "YUSAKU SENGA");

     setDonation(proofOfDonationCap, proofOfDonationCapOfWei);

  }

  function confirmed() external returns(bool) {

    tokenConfirmed();

    return true;

  }
}
  