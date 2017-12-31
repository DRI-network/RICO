![](https://dri.network/static/images/rico-banner.png)
[![npm version](https://badge.fury.io/js/rico-core.svg)](https://badge.fury.io/js/rico-core)
[![CircleCI](https://circleci.com/gh/DRI-network/RICO/tree/master.svg?style=shield)](https://circleci.com/gh/DRI-project/RICO/tree/master)
[![Slack Channel](https://dri-slack.now.sh/badge.svg)](https://dri-slack.now.sh/)

**This is an Alpha version and may still contain bugs. We are not responsible for any losses caused by this version.**

## Design Concept

RICO is a framework which forms a robust boilerplate for decentralized initial coin offerings (ICO). With RICO your ICO will be more responsible and be easier to set up and launch.

##### The problems with conventional ICO's

With a conventional ICO, the project owner can freely decide the process how tokens are generated. That is, the token design and holding ratio is decided by the project owner. After an initial issuance these tokens are sold to supporters at a certain price or exchanged for the total raised funds during the ICO.

##### RICO's approach

With RICO's approach the entire execution process of issuing tokens is strictly defined on the Ethereum Virtual Machine (EVM) and executed automatically. With RICO your ICO will be fully automatic and decentrilized. The decentrilized nature of an ICO created with RICO implements a true fair distribution system.

An ICO made with RICO is:
- Decentralized
- Autonomous
- Fair
- Mintable
- Easy to use

## Docs
### Whitepaper
- [Whitepaper[EN]](https://dri.network/static/RICO-whitepaper-en.pdf)
- [Whitepaper[JP]](https://dri.network/static/RICO-whitepaper.pdf)

### Tutorial
- [RICOTrutorial[JP]](https://scrapbox.io/DRI-community/RICO_Tutorial%EF%BC%88%E3%83%AA%E3%82%B3%E3%83%BC%E3%81%AE%E3%83%81%E3%83%A5%E3%83%BC%E3%83%88%E3%83%AA%E3%82%A2%E3%83%AB%EF%BC%89)


## Dependencies

- Mac OSX 10.13.1
- Node v9.0.0
- Truffle v4.0.1
- solidity-compiler v0.4.18

This project requires the [truffle framework](http://truffleframework.com/) to be installed globally. Please make sure you install this globally first:
```bash
$ npm install truffle@4.0.1 -g 
```
You can use ethereumjs-testrpc to test your RICO build.
```bash
$ npm install ganache-cli -g
```

## Getting Started 

### install rico-core
```bash
$ npm install -g rico-core
```

### new project generate
```bash
$ rico new ./helloico && cd ./helloico 
```

### Testnet deploy (ropsten)

**Caution: ropsten hit the Byzantium HardFork #1700000 you have to update geth to v1.7 and sync to the latest block.**

```
$ npm install truffle-hdwallet-provider
```
Attachment contracts:
```bash
$ export MNEMONIC_KEY="your mnemonic key 12 words" 
$ export RICO_ADDR=0xdc063bd44f1a395c5d1f3d4bdc75396aaf8b4b75
$ export LAUNCHER_ADDR=0x9851fa8938542234ed9261258dd19281a60f348a
$ truffle exec exec/KickStart/deploy.js --network ropsten
``` 

### Mainnet deploy

```bash
$ export MNEMONIC_KEY="your mnemonic key 12 words" 
$ export PRIV_KEY="your mnemonic key 12 words" 
$ export RICO_ADDR="non"
$ export LAUNCHER_ADDR="non"
$ truffle exec exec/KickStart/deploy.js --network mainnet
``` 

## SimpleICO Reference

### Overview

Out of the box RICO will give you an interface with usefull functions and a flexible token issuing scheme for your ICO.

The following code is an example of an ICO contract using RICO:

```js
contract Launcher {
  address public projectOwner;
  RICO public ico;
  string name = "Responsible ICO Token";
  string symbol = "RIT";
  uint8 decimals = 18;
  uint256 totalSupply = 400000 ether;                        // set the maximum supply to 400,000
  uint256 tobAmountToken = totalSupply * 2 / 100;            // set token "Take Over Bid" (TOB) ratio to 2% of the total supply
  uint256 tobAmountWei = 100 ether;                          // set ether TOB spent to 100 ether
  uint256 PoDCapToken = totalSupply * 50 / 100;              // set proof of donation token cap to 50% of the total supply
  uint256 PoDCapWei = 10000 ether;                           // set proof of donation ether cap to 10,000 ether
  uint256 firstSupply = totalSupply * 30 / 100;              // set the first token supply to 30% of the total supply
  uint256 firstSupplyTime = block.timestamp + 40 days;       // set the first mintable time to 40 days（after 40 days elapsed)
  uint256 secondSupply = totalSupply * 18 / 100;             // set the second token supply to 18% of the total supply
  uint256 secondSupplyTime = block.timestamp + 140 days;     // set the second mintable time to 140 days（after 140 days elapsed)
  address mm_1 = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC; // set the first market maker's address 
  uint256 mm_1_amount = 100 ether;                           // set the ether amount to 100 ether for the first market maker
  uint256 mmCreateTime = block.timestamp + 100 days;         // set the ether transferable time to 100 days
  uint256 PoDstrat = 0;                                      // set the token strategy

  function Launcher() {
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
```
This token issuing structure of the ICO is as shown in the figure below.
The token distribution round has been divided into two steps.

[![https://gyazo.com/0300b95fed0b436322212e26a7f9280b](https://i.gyazo.com/0300b95fed0b436322212e26a7f9280b.png)](https://gyazo.com/0300b95fed0b436322212e26a7f9280b)

### RICO's guideline APIs

#### function init()

```js
init (tokenFlag, totalSupply, tobAmountToken, tobAmountWei, PoDCapToken, PoDCapWei, PoDstrat, projectOwner);
```

This function initializes the RICO framework and deploys all dependency contracts.

##### params

| argument | type | description |
|:---|:---:|:---|
| tokenAddr | address | `tokenAddr` is an address of token contract. If you set this to `0x0` it will create a new token contract. |
| projectOwner | address | `projectOwner` is a parameter of for the "responsible token manager" in the RICO concept. If the Ethereum address is checksummed, it may unmatch an address that is unable to be checksummed while the EVM operates codes. |
| totalSupply | uint256 | `totalSupply` is a parameter to set the maximum supply quantity in the 'token strategy'. Literal `ether` means `10**18` on the EVM execution. This case is decimals equal 18, this token is available ether literal. E.g. `400000 ether` means that 400,000 Token will be mint. |
| tobAmountToken | uint256 | "Take Over Bid" (TOB) means that the tokens generated for the tender are locked for a certain period of time and can not be issued freely. The TOB price is defined by this token structure.<sup>1</sup> |
| tobAmountWei | uint256|  The project TOB Cap of ETH. |
| PoDCap | uint256| Proof of Donataion (PoD) is a reservation of token mint. If someone donates to the project, ether wire defined in EVM executes. params proxy to Dutch Auction contract in RICO contract.|
| PoDCapWei | uint256 | the project's hard-cap of ETH.|
| PoDstrat | uint256 | The 'Proof of Donation' strategy. `0` = normal, `1` = Dutch Auction |

<sup>1</sup> : People often ask why the token price is so cheap. We claim that the token price will touch the honestly price based on the prediction of the market actions. If the owner buying so cheaper price. but token has been locked by contract. The project owner has a much more positive reputation than the allocation strategy of many conventional ICOs.

#### function initTokenData()

```js
initTokenData (name, symbol, decimals);
```

EIP-20 is a TokenStandard Format on the Ethereum Blockchain.
`string` is a type in solidity. length **<= 32bytes**. name is a represent of Project name. sybmol is a represent of Project ticker symbol. decimals is a represent of token multiplexer 1 token = 1*10^multiplexer. e.g. "Responsible ICO Token" ,"RIT","18".

##### params
| argument | type | description |
|:---|:---:|:---|
| name | string | setting of token name. |
| symbol |string|  setting of token symbol. |
| decimals| uint8 | setting of token decimals. |

#### function addTokenRound()

```js
addTokenRound(roundSupply, execTime, to);
```

**Round** is most important precept that mean token distribution program. it least one needs to be defined on RICO token structure.

##### params

| argument | type | description |
|:---|:---:|:---|
|roundSupply|uint256| token mintable amount for this round.|
|execTime | uint256 | unlocking time and token creation time. adapt to `now` literal or `block.timestamp` reteral that return unixtimestamps.|
| to  | address| token will received address.|

#### function addWithdrawalRound()

```js
addWithdrawalRound(distributeWei, execTime, to, isMM);
```

This feature is more important precept of RICO Framework. project Owner will spent ether when TOB executed.and Proof of Donation send ether to RICO contract. that ether will be store to RICO contract.but anyone unable to sent ether from contract in that case. RICO has to diestribute ETH to someone from contract.this precept must be defined in token strategy to sending ETH to someone and this method will be called by projectOwner and receiver. To decide someone to be honestly we design incentive models. it seems to be market maker.

##### params 

| argument | type | description |
|:---|:---:|:---|
| distributeWei | uint256|  distribute ether amount to receiver. |
| execTime | uint256 |  unlocking distribute time. |
| to | address|  ether receive address.|
| isMM | bool|  this process executes for marketmaker or not; |

## Test 

### testing on ethereumjs-testrpc

running testrpc with account balance.

```bash
$ ./rpcrun.bash
```

```bash
$ truffle test 
```
### testing on ropsten testnet

please set the timeout to `this.timeout` if the block confirmation is too slow.

```bash
$ truffle test --network testnet
```

## LICENSE
RICO is licensed under the GNU General Public License v3.0.