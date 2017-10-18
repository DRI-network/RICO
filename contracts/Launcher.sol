pragma solidity ^0.4.15;
import "./RICO.sol";

/// @title SimpleICO - Sample ICO using with RICO Framework
/// @author - Yusaku Senga <senga@dri.network>
/// license let's see in LICENSE

contract Launcher {
  address owner;
  RICO ico;

  string name = "Responsible ICO Token";
  string symbol = "RIT";
  uint8 decimals = 18;
  uint256 totalSupply = 400000 ether; // 40万 Tokenを最大発行上限
  uint256 tobAmountToken = totalSupply * 2 / 100; // TOBの割合 2%
  uint256 tobAmountWei = 100 ether; // TOBでのETH消費量 100ETH
  uint256 PoDCap = totalSupply * 50 / 100; // PoDでの発行50%
  uint256 PoDCapWei = 10000 ether; // PoDでの寄付10000ETH
  uint256 PoDstrat = 0; // PoDの方法

  uint256 firstSupply = totalSupply * 30 / 100; // 1回目の発行量 30%
  uint256 firstSupplyTime = block.timestamp + 90 days; // 1回目の発行時間（生成時から90日後)
  uint256 secondSupply = totalSupply * 18 / 100; // 2回目の発行量　18%
  uint256 secondSupplyTime = block.timestamp + 180 days; // 1回目の発行時間（生成時から180日後)
  address mm_1 = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC; //マーケットメイカー
  uint256 mm_1_amount = 100 ether; //マーケットメイカーへの寄付額
  uint256 mmDistributeTime_1 = block.timestamp + 100 days; //マーケットメイカーの寄付実行時間

  modifier onlyOwner() {
    require(msg.sender == owner);
    /// Only owner is allowed to proceed
    _;
  }

  function Launcher() {}

  function init(address _rico) external onlyOwner() returns(bool) {
    ico = RICO(_rico);
    return true;
  }

  function setup(address _projectOwner) onlyOwner() returns(bool) {
    ico.init(0, totalSupply, tobAmountToken, tobAmountWei, PoDCap, PoDCapWei, PoDstrat, _projectOwner);
    ico.addTokenRound(firstSupply, firstSupplyTime, _projectOwner);
    ico.addTokenRound(secondSupply, secondSupplyTime, _projectOwner);
    ico.addMarketMaker(mm_1_amount, mmDistributeTime_1, mm_1, "YUSAKUSENGA");
    return true;
  }

}