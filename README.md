# Responsible Initial Coin Offering ( RICO ) Framework 

**Please be careful. This Version is Alpha. application may contain bugs.We are not responsible for any losses caused by this version.**

This framework is a decentralized framework, that makeing the initial coin offering more responsible and decentralized.

## Design Concept

In the case of the conventional ICO, the project owner can freely decide the process of generating the token. That is, the token design and token holding ratio is determined by the project owner. The sale of the token is done after issuance, and the project supporter purchases the issued token.

In our approach, all execution processes of issuing tokens are strictly defined on the Ethereum Virtual Machine (EVM) and executed automatically. In addition, by automatically controlling the step of token generation, we can implement fair distribution for promoting system decentralization.

- Autonomous
- Comfortable 
- Decentralizing
- Equitable
- Mintable

## Dependencies

- Node v8.4.0
- Truffle v4.0.1
- solidty-compiler v0.4.18

This project using truffle framework, you can install truffle framework first.
reference for truffle => [truffle](http://truffleframework.com/)

```
$ npm install truffle@4.0.1 -g 
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

### mainnet deploy

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

### Overview
RICO has several GuidLine API for ICOs. By combining these interfaces, implementing a flexible token issuing scheme. it call the token structure.
This code is an example of an ico contract using RICO.

```js
pragma solidity ^0.4.18;
import "./RICO.sol";
import "./Ownable.sol";

contract Launcher is Ownable {
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


  function Launcher() public {}

  function init(address _rico, address _token, address _pod) public onlyOwner() returns(bool) {
    ico = RICO(_rico);
    ico.init(_token, totalSupply, tobAmountToken, tobAmountWei, PoDCapToken, PoDCapWei, _pod, owner);
    return true;
  }

  function setup() public onlyOwner() returns(bool) {
    ico.initTokenData(name, symbol, decimals);
    ico.addTokenRound(firstSupply, firstSupplyTime, owner);
    ico.addTokenRound(secondSupply, secondSupplyTime, owner);
    ico.addWithdrawalRound(mm_1_amount, mmCreateTime, mm_1, true);
    ico.addWithdrawalRound(PoDCapWei, mmCreateTime, owner, false);
    return true;
  }
}
```
This Token issuing structure of the ICO is as shown in the figure below.
Token distribute round has been divided by two steps.

[![https://gyazo.com/0300b95fed0b436322212e26a7f9280b](https://i.gyazo.com/0300b95fed0b436322212e26a7f9280b.png)](https://gyazo.com/0300b95fed0b436322212e26a7f9280b)

### RICO Guidline API

#### function init(tokenAddr, totalSupply, tobAmountToken, tobAmountWei, PoDCapToken, PoDCapWei, PoDAddr, projectOwner);
This function implement initialize RICO Framework and deploy all dependency contracts.
##### params
| argument | type | description |
|:---|:---:|:---|
| tokenAddr | address | tokenAddr is a Address of token Contract. if you can use `0x0`, will be create new Token contract. |
| totalSupply | uint256 | totalSupply is a params maximum supply quantities in Token strategy. literal `ether` mean 10**18 on EVM execution. this case is decimals equal 18, this token available ether literal.`400000 ether` mean that 400,000 Token will be mint. |
| tobAmountToken | uint256 | TOB executes meaning the token generated by the tender offer is locked for a certain period of time and can not be issued freely. and TOB price defined by this token structure. people ask the question that token price is so cheaper ? but we claim that token price will touch the honestly price based on the prediction market action. if the owner buying so cheaper price. but token has been locked by contract. project owner has huge positive reputation rather than many conventional ICOs strategy **allocations**. |
| tobAmountWei | uint256|  Project TOB Cap o ETH. |
| PoDCapToken | uint256| Proof of Doantaion (PoD) is a reservation of Token mint. if donate to project, ether wire defined in EVM executes. params proxy to Dutch Auction contract in RICO contract.|
| PoDCapWei | uint256 | Project HardCap of ETH.|
| PoDAddr | address | PoD Contract's address. sample be in /PoDs|
| projectOwner | address | projcetOwner is a params of responsible token manager in RICO concept.if Ethereum address is checksumed, it may unmatch address that unable checksumed while the EVM operate codes. |


#### function initTokenData(name, symbol, decimals)

EIP-20 is a TokenStandard Format on the Ethereum Blockchain.
`string` is a type in solidity. length **<= 32bytes**. name is a represent of Project name. sybmol is a represent of Project ticker symbol. decimals is a represent of token multiplexer 1 token = 1*10^multiplexer. e.g. "Responsible ICO Token" ,"RIT","18".

##### params
| argument | type | description |
|:---|:---:|:---|
| name | string | setting of token name. |
| symbol |string|  setting of token symbol. |
| decimals| uint8 | setting of token decimals. |

#### function addTokenRound(roundSupply, execTime, to);

**Round** is most important precept that mean token distribution program. it least one needs to be defined on RICO token structure.
##### params
| argument | type | description |
|:---|:---:|:---|
|roundSupply|uint256| token mintable amount for this round.|
|execTime | uint256 | unlocking time and token creation time. adapt to `now` literal or `block.timestamp` reteral that return unixtimestamps.|
| to  | address| token will received address.|

#### function addMarketMaker(distributeWei, execTime, maker, metaData)

This feature is more important precept of RICO Framework. project Owner will spent ether when TOB executed. that ether will be send to RICO contract.but anyone unable to sent ether from contract in that case. RICO has to diestribute ETH to someone from contract.this precept must be defined in token strategy to sending ETH to someone and this method will be called by projectOwner. To decide someone to be honestly we design incentive models. it seems to be market maker.
##### params 
| argument | type | description |
|:---|:---:|:---|
| distributeWei | uint256|  distribute ether amount for this project. |
| execTime | uint256 |  unlocking distribute time. |
| maker | address|  ether receive address.|
| metaData | uint256|  market maker name or meta payload; |

## Test 

### testing on ethereumjs-testrpc
running testrpc with account balance.
```
testrpc -p 9545 -l 4700000 --account="0x8445abbbcf2911a2db42fced93efe0d7b3172295c99b01a9e02197ff52f30a53,200000000000000000000" --account="0x580324cb2abc8029d6eb5a14650a8bd77f48be478c7ece07afd777755070128c,200000000000000000000" --account="0x3e478e4fed09cdc68388286b94aeb1404df47b1f1df0de715e582d6aebc6e1c9,200000000000000000000" --account="0xa0d45d6a3911221c4e1b7edcd256741c6bcb9a247fda017a8946ff5f5c38021a,200000000000000000000" --account="0x1386ff12f7d49e6e4e835952493d034570e134bfb0fc6f9d17b49dbdf88d03b3,200000000000000000000" --account="0xf84d5b9d64e427d43645e3c12906d322410a87b277374a0335a4ca0da9316d23,200000000000000000000"
```

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
