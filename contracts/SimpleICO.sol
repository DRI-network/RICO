pragma solidity ^0.4.15;
import "./RICO.sol";

/// @title SimpleICO - Sample ICO using with RICO Framework
/// @author - Yusaku Senga < syrohei@gmail.com >

 contract SimpleICO is RICO {
   string  name = "Responsible ICO Token";
   string  symbol = "RIT";
   uint8   decimals = 18;
   uint256 totalSupply = 400000 ether;                    // 40万 Tokenを最大発行上限
   uint256 tobAmountToken = totalSupply * 2 / 100;        // TOBの割合 2%
   uint256 tobAmountWei = 100 ether;                      // TOBでのETH消費量 100ETH
   uint256 PoDCap = totalSupply * 30 / 100;               // PoDでの発行30%
   uint256 PoDCapWei = 10000 ether;                       // PoDでの寄付10000ETH

   uint256 firstSupply = totalSupply * 30 / 100;          // 1回目の発行量 30%
   uint256 firstSupplyTime = block.timestamp + 40 days;   // 1回目の発行時間（生成時から40日後)
   uint256 secondSupply = totalSupply * 38 / 100;         // 2回目の発行量　38%
   uint256 secondSupplyTime = block.timestamp + 140 days; // 1回目の発行時間（生成時から40日後)
   address mm_1 = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC; //マーケットメイカー
   uint256 mm_1_amount = 100 ether;                           //マーケットメイカーへの寄付額
   uint256 mmDistributeTime_1 = block.timestamp + 100 days;         //マーケットメイカーの寄付実行時間
   
 
   function SimpleICO() { } 
 
   function init(address _projectOwner) external onlyOwner() returns (bool) {
     init(totalSupply, tobAmountToken, tobAmountWei, PoDCap, PoDCapWei, _projectOwner);
     initTokenData(name, symbol, decimals);
     addTokenRound(firstSupply, firstSupplyTime, _projectOwner);
     addTokenRound(secondSupply, secondSupplyTime, _projectOwner);
     addMarketMaker(mm_1_amount, mmDistributeTime_1, mm_1, "YUSAKUSENGA");
     return true;
   }
 }