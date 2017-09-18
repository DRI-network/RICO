/**
 * @title SafeMath from https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 * @dev Math operations with safety checks that throw on error
 */
pragma solidity ^0.4.15;
import "./Token.sol";
import "./SafeMath.sol";

contract RECO {

  using SafeMath for uint256;

  struct Round {
    uint256 roundSupply;
    uint256 voteTime;
  }

  struct TokenStructure {
    uint256 totalSupply;
    address po;
    uint256 tobAmount;
    uint256 tobPrice;
    uint256 voteTime;
    uint256 actionTime;
  }

  enum Status {
    TokenInit,
    TokenSubmitted,
    TokenConfirmed,
    TokenCreated,
    TokenReserve,
    TokenMintRound
  }

  address owner;
  TokenStructure ts;
  Token token;
  Round[] rounds;
  mapping(uint256 => mapping(bool => uint256)) votePowers;
  mapping(address => uint256) weiBalances;
  string tokenName;
  string tokenSymbol;
  uint8 tokenDecimals;


  Status status = Status.TokenInit;

  function RECO() {
    owner = msg.sender;
  }

  function initTokenData(string _name, string _symbol, uint8 _decimals) {

    require(status == Status.TokenInit);

    tokenName = _name;
    tokenSymbol = _symbol;
    tokenDecimals = _decimals;
  }

  function submitToken(uint256 _totalSupply, uint256 _tobAmount, uint256 _tobPrice, uint256 _voteTime) returns(bool) {

    require(status == Status.TokenInit);

    token = new Token();

    ts = TokenStructure({
      totalSupply: _totalSupply,
      po: msg.sender,
      tobAmount: _tobAmount,
      tobPrice: _tobPrice,
      voteTime: _voteTime,
      actionTime: block.timestamp
    });

    status = Status.TokenSubmitted;
  }

  function vote(bool _agreement) payable returns(bool) {

    require(msg.value != 0);

    //VotePower is Deposit ETH wei balance;
    uint256 votePower = msg.value;

    uint256 stat = uint256(status);

    if (status == Status.TokenMintRound) {
      stat = stat.add(20);
    }

    votePowers[stat][_agreement] = votePowers[stat][_agreement].add(votePower);

    weiBalances[msg.sender] = weiBalances[msg.sender].add(msg.value);

    return true;
  }

  function confirmation() {

    require(ts.actionTime.add(ts.voteTime) < block.timestamp);

    if (status == Status.TokenSubmitted) {
      execTokenSubmitConf();
    }

    ts.actionTime = block.timestamp;
  }

  function execTokenSubmitConf() {

    require(status == Status.TokenSubmitted);

    uint256 stat = uint256(status);

    if (votePowers[stat][true] > votePowers[stat][false]) {

      token.init(tokenName, tokenSymbol, tokenDecimals);
     
      execTob();

      status = Status.TokenConfirmed;

    } else {

      token.destruct();

      status = Status.TokenInit;

    }

  }

  function execTob() {
    
    require(msg.sender == ts.po);

    uint256 amountWei = ts.tobAmount / ts.tobPrice;

    require(weiBalances[msg.sender] > amountWei);

    require(token.mint(ts.po, ts.tobAmount));

    weiBalances[msg.sender] = weiBalances[msg.sender].sub(amountWei);

  }

  function submitRound(uint256 _roundSupply) {

    require(status == Status.TokenConfirmed);

    Round memory round = Round({
      roundSupply: _roundSupply,
      voteTime: ts.voteTime
    });

    rounds.push(round);

  }


}