pragma solidity ^0.4.18;
import "./EIP20StandardToken.sol";
import "./SafeMath.sol";
import "./Freezable.sol";

/// @title RICOToken - RICOToken Standard
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract RICOToken is EIP20StandardToken, Freezable {
  /// using safemath
  using SafeMath
  for uint256;
  /// declaration token name
  string public name;
  /// declaration token symbol
  string public symbol;
  /// declaration token decimals
  uint8 public decimals;


  enum Status {
    Deployed,
    Initialized
  }

  struct Mint {
    uint256 amount;
    uint256 atTime;
  }

  mapping(address => Mint[]) public issuable;
  Status status;


  /**
   * Event
   */

  event Issued(address user, uint256 amount);

  /**
   * constructor
   * @dev define owner when this contract deployed.
   */
  function RICOToken() public {
    owner = msg.sender;
    status = Status.Deployed;
  }

  /** 
   * @dev initialize token meta Data implement for ERC-20 Token Standard Format.
   * @param _name         set Token name.
   * @param _symbol       set Token symbol.
   * @param _decimals     set Token decimals.
   */
  function init(string _name, string _symbol, uint8 _decimals) external onlyOwner() returns(bool) {
    require(status == Status.Deployed);
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    status = Status.Initialized;
    return true;
  }

  /** 
   * @dev Add mintable token to user verified owner.
   * @param _user         set minting user address.
   * @param _amount       set minting token quantities.
   * @param _atTime       set minting time of mintable
   */
  function mintable(address _user, uint256 _amount, uint256 _atTime) external can() onlyOwner() returns(bool) {

    require(block.timestamp <= _atTime);

    Mint memory m = Mint({
      amount: _amount,
      atTime: _atTime
    });
    issuable[_user].push(m);
    return true;
  }


  /**
   * @dev all minting token to user verified by owner.
   * @param _user         call user address for minting users token.
   */
  function mint(address _user) external returns(bool) {

    for (uint n = 0; n < issuable[_user].length; n++) {

      Mint memory m = issuable[_user][n];

      if (isExecutable(m.atTime) && m.amount > 0) {

        balances[_user] = balances[_user].add(m.amount);
        totalSupply = totalSupply.add(m.amount);
        Issued(_user, m.amount);
        delete issuable[_user][n];
      }
    }
    return true;
  }

  /**
   * @dev changeable for token owner.
   * @param _newOwner set new owner of this contract.
   */
  function changeOwner(address _newOwner) external can() onlyOwner() returns(bool) {
    require(_newOwner != 0x0);

    owner = _newOwner;

    return true;
  }

  /**
   * @dev constant return status whether time elapsed.
   * @param _executeTime  set a elapsed time of to be executable.
   */
  function isExecutable(uint256 _executeTime) internal constant returns(bool) {
    if (block.timestamp < _executeTime) {
      return false;
    }
    return true;
  }
}