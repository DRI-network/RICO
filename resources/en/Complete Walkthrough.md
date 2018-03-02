# A Complete Walkthrough to a Responsible ICO

If you are in the market to do an ICO, chances are big that you want to be able to show the world you are doing it responibly!

RICO is a framework to be bootstrap your ICO and have a fair and transparent ICO. Moreover it's super easy to kickstart your ICO with just changing a few parameters! All the heavy lifting is done entirely by the RICO framework. RICO was created by the Tokyo Ethereum community: DRI - Decentralizedtech Research Institute.

Today I'll show you how easy it is to create a RICO ("Responsible ICO").

- [1. Setup](#1-setup)
- [2. Studying the contracts](#2-studying-the-contracts)
  - [What are RICO Standard ICO's benefits?](#what-are-rico-standard-icos-benefits)
- [3. Set up a test server](#3-set-up-a-test-server)
- [4. Set our RICO Standard ICO's parameters](#4-set-our-rico-standard-icos-parameters)
- [5. Deploy the RICO Contracts](#5-deploy-the-rico-contracts)
  - [Interact with RICO in the console](#interact-with-rico-in-the-console)
  - [Check user balances](#check-user-balances)
- [6. Setup a 'CreatedNewProject' listener](#6-setup-a-creatednewproject-listener)
- [7. Deploy my RICO Standard ICO](#7-deploy-my-rico-standard-ico)
  - [Interact with your RICO Standard ICO in the console](#interact-with-your-rico-standard-ico-in-the-console)
- [8. Start your ICO!](#8-start-your-ico)
  - [Making the Take Over Bid](#making-the-take-over-bid)
  - [Making donations for the public sale](#making-donations-for-the-public-sale)
  - [Conclusion of your Responsible ICO](#conclusion-of-your-responsible-ico)
- [Conclusion](#conclusion)


## 1. Setup

Let's setup our dependencies:

```bash
$ npm install truffle@4.0.1 -g 
$ npm install solidity-compiler -g
$ npm install ganache-cli -g
$ npm install rico-core -g
```

Then generate your RICO folder:

```bash
$ rico new MyFirstRICO
```

## 2. Studying the contracts

When you look inside the folder you'll see a dozen contracts that make up the RICO framework. We'll just focus on the important ones that will make it possible for us to create an ICO within 5 minutes.

RICO currently has several templates that allow to kickstart your ICO with a certain setup:

- The RICO standard ICO.
- A traditional ICO with a lock time for the owner tokens.
- A Dutch Auction ICO
- A DAICO modelled ICO

Today we will focus on the RICO standard ICO.

### What are RICO Standard ICO's benefits?

The RICO standard ICO includes the following benefits:

**A Take Over Bid**: This is an initial deposit by the owner for a separate allocation of the ICO tokens. With RICO even the owners invest some ether for their share of the tokens.

**Supporting the market makers**: RICO has a system to automatically send the owner's initial investment as fee to the market makers after the ICO concludes.

**Lock time for the owner tokens**: The tokens allocated for the owner is locked up for a fixed period of 180 days.

**All registration and handling of donations is taken care of**: Otherwise it wouldn't be an ICO framework right! :D

## 3. Set up a test server

It's always smart to first test out your RICO on a testnet. We prepared a custom testrpc setting you can execute from the home directory of your RICO project folder:

```bash
$ chmod +x rpcrun.bash
# ↑ Mac only (make rpcrun executable)
$ ./rpcrun.bash
```

Please take note of the 6 addresses that were generated, as we'll be using them in the next step.

## 4. Set our RICO Standard ICO's parameters

Now let's fill in our ICO's details. RICO comes with a handy deploy script at `exec/KickStarter/deploy.js`.

The values we want to overwrite in this deploy script are these:

- `totalTokenSupply`: Our ICO will sell 400,000 tokens. This default is fine. (it has 18 zeros added to represent the token supply just like Wei)
- `publicSaleTokenSupply`: 90% of the tokens is for the public sale.
- `publicSaleWeiCap`: It's a small project, lets value the 90% of the tokens at 100 ETH. (about 30,000 USD)
- `multisigWalletAddress`: Multisig addresses 1 can be left empty, which will default to the user sending the transaction (aka account[0]) for the second owner we can use another account who will be co-owning the ICO's wallet.
- `TOBTokenSupply`: By default set to 8%, but since there is no second owner it will include the `secondOwnerAllocation` making a total of 10% in return for the Take Over Bid.
- `TOBPrice`: (in Wei) Set to `10 * 10 ** 18` to pay 10 ETH for your Take Over Bid.
- `marketMaker`: let's set the market maker address to a friend who will be responsible for advertising our ICO (He'll receive the 10 ETH we paid).

This is all we need! Now let's deploy our RICO Standard ICO!

## 5. Deploy the RICO Contracts

It's time to launch our ICO!
The way RICO works is that the RICO and Launcher contracts are singletons: They are only deployed onto the blockchain once, and people can use these to create their own ICO contracts. For the sake of this tutorial I'll quickly deploy the RICO contracts onto the local testnet:

```bash
$ truffle migrate --reset --network testrpc
```

### Interact with RICO in the console

Let's play around with the truffle console and interact with the deployed RICO contracts to make sure everything works correctly.

```bash
$ truffle console --network testrpc
# In the truffle console paste:
> RICO.deployed().then(instance => { app = instance })
```

Now we have our RICO instance to perform functions. Let's check the RICO version like so:

```js
> app.version().then(v => console.log('version: ', v))
```

In case you get the latest RICO version logged, everything is working properly!

### Check user balances

Remember how we had set up the test accounts?
We are using accounts [1], [2] and [3] to invest into our RICO.
[0] is the project owner, [5] is the second owner and [4] is the market maker.
Let's make a function to check the balances of all our test accounts:

```js
const allBalances = _ => {
  console.log(`【BALANCES】
[0] Owner: ${web3.fromWei(web3.eth.getBalance(web3.eth.accounts[0]), 'ether')}
[1] Supporter 1: ${web3.fromWei(web3.eth.getBalance(web3.eth.accounts[1]), 'ether')}
[2] Supporter 2: ${web3.fromWei(web3.eth.getBalance(web3.eth.accounts[2]), 'ether')}
[3] Supporter 3: ${web3.fromWei(web3.eth.getBalance(web3.eth.accounts[3]), 'ether')}
[4] Market maker: ${web3.fromWei(web3.eth.getBalance(web3.eth.accounts[4]), 'ether')}
[5] Second owner: ${web3.fromWei(web3.eth.getBalance(web3.eth.accounts[5]), 'ether')}
  `)
}
```

However, the problem is that the truffle console does not accept multi-line functions. An easy work around is to save it to a js file in your RICO project folder and execute it from the truffle console.

1. Make a file called `allBalances.js` in the home directory of your RICO project.
2. Paste the function above, add `allBalances()` at the end and save.
3. Go back to the truffle console and execute: `exec ./allBalances.js`

Now you can see a nice overview of all your balances for your test accounts.

## 6. Setup a 'CreatedNewProject' listener

Your own ICO to be deployed on the blockchain will use two other contracts. In the case of RICO Standard ICO these contracts are `PublicSalePoD.sol` and `RICOStandardPoD.sol`. These are PoDs, short for Proof of Donation. They will handle the actual donations and allocation of tokens etc.

In order to know on which addresses our RICO Standard ICO PoDs will be deployed, we need to first setup an event listener that can notify us of a new project created through RICO.

```js
> RICO.deployed().then(instance => { app = instance })
> var newProjectEvent = app.CreatedNewProject({}, {}).watch((error, event) => { console.log(event) })
```

## 7. Deploy my RICO Standard ICO

Now all we need to do is to use execute the `deploy.js` script. It will send all our ICO parameters we set up to the Launcher contract.
```bash
# cd to your MyFirstRICO directory:
# Paste the correct contract address of the deployed RICO contract.
$ export RICO_ADDR=0x1c6f2526b0a5128b89ee0f921f8b8b794189f2ed
# Paste the correct contract address of the deployed Launcher contract.
$ export LAUNCHER_ADDR=0x39326f43557b33afdad3cec0d0272619c0d7ad9b
# Run the deploy.js script.
$ truffle exec exec/KickStarter/deploy.js --network testrpc
```

(For the testnet: Our truffle migration script tells you the the RICO and Launcher addresses, so search in your terminal after you had migrated.)

First of all, take note of the console that logged out your Multisig wallet address. We'll need this address later on.

At the same time your event listener in the truffle console will notify you of your project's Proof of Donation addresses. You should see something in the lines of:

```js
  event: 'CreatedNewProject',
  args:
    { name: 'Responsible ICO Token',
      symbol: 'RIT',
      decimals: BigNumber { s: 1, e: 1, c: [Array] },
      supply: BigNumber { s: 1, e: 23, c: [Array] },
      pods:
        [ '0x4ab220389e764e5ffd71b9eb104ca7ae775bb3af',
        '0x88c8e8a3967830dd305e62967b4b0a1dcfdc2896' ],
      token: '0xac39bd3d383b216de8fe8d6c0e8317cb2321981c' }
```

Here you can take note of the two addresses of your Proof of Donations. The first PoD address being the `RICOStandardPoD.sol` address and the second one the `PublicSalePoD.sol`. You will need these addresses to interact with your responsible ICO. Also keep note of your token address, as you'll need this later on.

### Interact with your RICO Standard ICO in the console

Let's check if our RICO Standard ICO was created with the values that we have chosen in `deploy.js`.

First retrieve the RICOStandardPoD and PublicSalePoD instances in the truffle console:

```js
// Paste the correct addresses of your PoDs.
> RICOStandardPoD.at('0x4ab220389e764e5ffd71b9eb104ca7ae775bb3af').then(inst => { ricopod = inst })
> PublicSalePoD.at('0x88c8e8a3967830dd305e62967b4b0a1dcfdc2896').then(inst => { salepod = inst })
```

The values we want to check:

```js
totalTokenSupply = 400000
publicSaleTokenSupply = 400000*90%
publicSaleWeiCap = 100 ETH
TOBTokenSupply = 400000*10%
TOBPrice = 10 ETH
```

```js
> ricopod.getCapOfToken().then(_ => console.log('getCapOfToken: ', _.toString()))
> ricopod.getCapOfWei().then(_ => console.log('getCapOfWei: ', _.toString()))
> ricopod.getTokenPrice().then(_ => console.log('getTokenPrice: ', _.toString()))
> salepod.getCapOfToken().then(_ => console.log('getCapOfToken: ', _.toString()))
> salepod.getCapOfWei().then(_ => console.log('getCapOfWei: ', _.toString()))
> salepod.getTokenPrice().then(_ => console.log('getTokenPrice: ', _.toString()))
```

Check the values:

- PublicSalePoD's amount of tokens is capped at `3.6e+23`. If we remove 18 zeros we'll have `3.6e+5` which is `360000`.
- The cap of Wei is `100000000000000000000` which is `100` ETH.
- Effectively making the token price `277777777777777` per token-wei. So 277777777777777/1e18 brings our price per token at `0.00027777777` ETH per token. Do this times 360000 and we're at 100 ETH.
- RICOStandardPoD's total token amount is `4e+22` representing the remaining `40000` tokens.
- The cap of Wei is 10 ETH.
- The price is .00025 ETH per token.

Everything seems to be correct.

## 8. Start your ICO!

Congratulations! You're ready to start your ICO! You've succesfully deployed the RICO framework and kick started your own Responsible ICO!

Now you just need to inform all your supporters how to donate so let's simulate the actual process. First let's set up an event listener to receive information on all donations that are received.

```js
// In truffle console, use the same ricopod and salepod instances from the last step.
> var newDonateEventTOB = ricopod.Donated({}, {}).watch((error, event) => { console.log(event, error) })
> var newDonateEventPublicSale = salepod.Donated({}, {}).watch((error, event) => { console.log(event, error) })
```

### Making the Take Over Bid

Before we start receiving donations let's first donate our 10 ETH we set for the Take Over Bid. This can be sent to the `donate()` function of the RICO standard PoD. However, if you remember from our `deploy.js` script we have set the start of the Take Over Bid to `now + 7200` seconds. You can check the `PoDStartTime` by calling `getStartTime()`.

Let's check the start time, make time pass on the testnet and make our donation for our Take Over Bid:

```js
// Make sure you still have your ricoPoD instance:
> RICOStandardPoD.at('0x4ab220389e764e5ffd71b9eb104ca7ae775bb3af').then(inst => { ricopod = inst })
// Get the ricoPoD startTime and the current timestamp:
> ricopod.getStartTime()
> web3.eth.getBlock(web3.eth.blockNumber).timestamp
// Move time forward by 7200 seconds:
> web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [72000], id: 0})
> web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0})
> web3.eth.getBlock(web3.eth.blockNumber).timestamp
// Now make your Take Over Bid donation:
> ricopod.donate({value: web3.toWei(10, 'ether'), gas: '700000', from: web3.eth.accounts[0]})
// Check the status of your PoD:
> ricopod.isPoDEnded().then(response => console.log('isPoDEnded: ', response))
```

We have donated 10 ETH to the RICOStandardPoD and the PoD has concluded itself. However, if we check our token-balance with our RICOStandardPoD, we'll see that it still says 0.

```js
> ricopod.getBalanceOfToken(web3.eth.accounts[0]) // returns 0
```

This is because the tokens the owner receives are only accesible after 180 days. After we finish our public sale we'll fast forward 180 days and see what will happen.

### Making donations for the public sale

Let's get our PublicSalePoD instance and make some donations until 100 ETH:

```js
// Retrieve the public sale PoD instance:
> PublicSalePoD.at('0x88c8e8a3967830dd305e62967b4b0a1dcfdc2896').then(inst => { salepod = inst })
// Fast forward time to the start of the public sale:
> salepod.getStartTime()
> web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [172800], id: 0})
> web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0})
> web3.eth.getBlock(web3.eth.blockNumber).timestamp
// Make them donations!
> salepod.donate({value: web3.toWei(50, 'ether'), gas: '700000', from: web3.eth.accounts[1]})
> salepod.donate({value: web3.toWei(40, 'ether'), gas: '700000', from: web3.eth.accounts[2]})
> salepod.donate({value: web3.toWei(20, 'ether'), gas: '700000', from: web3.eth.accounts[3]})
// Let's check the new balances:
> exec ./allBalances.js
```

Now you might wonder, where has the 100 ETH that was raised gone? It's in that multisig wallet that was created when we deployed our RICO.

```js
> web3.fromWei(web3.eth.getBalance('0x1104c5adf4476aec333ee687c725eacc8d417a7c'), 'ether')
```

Let's see if our supporters got their tokens:

```js
> salepod.getBalanceOfToken(web3.eth.accounts[1])
> salepod.getBalanceOfToken(web3.eth.accounts[2])
> salepod.getBalanceOfToken(web3.eth.accounts[3])
```

### Conclusion of your Responsible ICO

#### Minting tokens for your supporters

Currently there is a ledger with the balances of who owns how many tokens in your publicSalePoD. The next step is to mint the tokens through the RICO contract.

We'll need the token address from the `CreatedNewProject` event listener. In your `mintToken()` function you need to fill in the token address as the first parameter and `1` for public sale as the second parameter. The third parameter is the user you want to mint the tokens for.

```js
// Make sure we still have the RICO instance:
> RICO.deployed().then(instance => { app = instance })
> app.mintToken('0xac39bd3d383b216de8fe8d6c0e8317cb2321981c', 1, web3.eth.accounts[1])
// Get the token instance where the tokens are minted per user:
> MintableToken.at('0xac39bd3d383b216de8fe8d6c0e8317cb2321981c').then(instance => { tokens = instance })
// Check the balance after the tokens have been minted:
> tokens.balanceOf(web3.eth.accounts[1])
> salepod.getBalanceOfToken(web3.eth.accounts[1])
```

Now you can see that the tokens of your users have been moved from your Proof of Donation contract to the Mintable Token contract.

#### What about the market maker?

The 10 ETH we paid for the Take Over Bid is going to the market maker and can be transferred via the `distributeWei()` function:

```js
> ricopod.distributeWei(0, web3.toWei(10, 'ether'))
> exec ./allBalances.js
```

#### Retrieve Take Over Bid tokens

One last thing to do before we can call it a day (or a RICO) is to receive the tokens that were kept for the owners. In this case we have make a Take Over Bid that has allocated 10% of the total tokens to be transferred to our owners after 180 days.

Let's try passing 180 days on our testnet and see what happens:

```js
// Pass 180 days in seconds through the evm_increaseTime method:
> web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [15552000], id: 0})
> web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0})
// Recheck if we have a token balance:
> ricopod.getBalanceOfToken(web3.eth.accounts[0])
// Enjoy your tokens!
```

## Conclusion

Phew, what a journey! Today we've seen how anyone can easily do a Responible ICO. Just set a few parameters for your project and you're good to go!

Happy RICO'ing!

-Luca Ban
DRI, Tokyo
Decentralizedtech Research Institute
