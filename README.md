# Responsible Initial Coin Offering ( RICO ) Framework 

**Please be careful. This Version is Alpha. application may contain bugs.**

This framework is a decentralized framework, that makeing the initial coin offering more responsible.

## Motivation

- Autonomous
- Comfortable 
- Decentralizing
- Equitable
- Mintable

## Dependencies

- Node v8.4.0
- Truffle v3.4.9
- solidty-compiler v0.4.15

This project using truffle framework, you can install truffle framework first.
reference for truffle => [truffle](http://truffleframework.com/)

```
$ npm install truffle@3.4.9 -g 
```
And you can using ethereumjs-testrpc for testing.
```
$ npm install ethereumjs-testrpc -g
```

## Getting Started 

### ropsten testnet deploy
Set up etheruem Geth node with modules.
```
$ geth --fast --rpc --testnet --rpcaddr "0.0.0.0" --rpcapi "personal,admin,eth,web3,net"
```
**Caution ropsten hit a Byzantium HardFork #1700000 you have to update geth to v1.7 and sync latest block.**

Add configuration to truffle.js 
```js
 testnet: {
      host: "192.168.0.103",  // geth rpc addr
      port: 8545,
      network_id: 3, // Match ropsten network id
      gas: 4612188,
      gasPrice: 30000000000
 }
  
```

Deploy Contracts.
```
$ truffle migrate --network testnet
``` 

### mainet deploy

Add configuration to truffle.js
```js
mainnet: {
      host: "10.23.122.2",
      port: 8545,
      network_id: 1, // Match main network id
      gas: 6312188,
      gasPrice: 30000000000
}
```
```
$ truffle migrate --network mainnet
``` 

## SimpleICO Reference


```
 contract SimpleICO is RICO {
   string  name = "Responsible ICO Token";
   string  symbol = "RIT";
   uint8   decimals = 18;
   uint256 totalSupply = 400000 ether;                    // 40万 Tokenを最大発行上限
   uint256 tobAmountToken = totalSupply * 1 / 100;        // TOBの割合 10%
   uint256 tobAmountWei = 100 ether;                      // TOBでのETH消費量 100ETH
   uint256 PoDCap = totalSupply * 20 / 100;               // PoDでの発行20%
   uint256 poDCapWei = 10000 ether;                       // PoDでの寄付10000ETH

   uint256 firstSupply = totalSupply * 10 / 100;          // 1回目の発行量 10%
   uint256 firstSupplyTime = block.timestamp + 40 days;   // 1回目の発行時間（生成時から40日後)
   uint256 secondSupply = totalSupply * 69 / 100;         // 2回目の発行量　69%
   uint256 secondSupplyTime = block.timestamp + 140 days; // 1回目の発行時間（生成時から40日後)
   address mm_1 = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC; //マーケットメイカー
   uint256 mm_1_amount = 100 ether;                           //マーケットメイカーへの寄付額
   uint256 mmCreateTime = block.timestamp + 100 days;         //マーケットメイカーの寄付実行時間
   
 
   function SimpleICO() { } 
 
   function init(address _projectOwner) external onlyOwner() returns (bool) {
     init(totalSupply, tobAmountToken, tobAmountWei, PoDCap, poDCapWei, _projectOwner);
     initTokenData(name, symbol, decimals);
     addRound(firstSupply, firstSupplyTime, _projectOwner);
     addRound(secondSupply, secondSupplyTime, _projectOwner);
     addMarketMaker(mm_1_amount, mmCreateTime, mm_1, "YUSAKU SENGA");
     return true;
   }
 }
```

## Test 

### testing on ethereumjs-testrpc

```
$ truffle test 
```
### testing on ropsten testnet

please set timeout `this.timeout` if block confirmation too slow. 

```
$ truffle test --network testnet
```

## LICENSE
RICO is licensed under the GNU General Public License v3.0.
