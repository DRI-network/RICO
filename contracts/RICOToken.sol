pragma solidity ^0.4.15;
import "./EIP20TokenStandard.sol";
import "./SafeMath.sol";

/// @title RICOToken - RICOToken Standard
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract RICOToken is EIP20TokenStandard {
  /// using safemath
  using SafeMath for uint256;
  /// declaration token name
  string public name;
  /// declaration token symbol
  string public symbol;
  /// declaration token decimals
  uint8 public decimals;
  /// declaration token owner
  address public owner;

  mapping(address => Mint[]) public mints;

  struct Mint {
    uint256 amount;
    uint256 atTime;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    /// Only owner is allowed to proceed
    _;
  }

  /**
   * constructor
   * @dev define owner when this contract deployed.
   */
  function RICOToken() {
    owner = msg.sender;
  }

  /** 
   * @dev initialize token meta Data implement for ERC-20 Token Standard Format.
   * @param _name         representation of Token name.
   * @param _symbol       representation of Token symbol.
   * @param _decimals     representation of Token decimals.
   */

  function init(string _name, string _symbol, uint8 _decimals) external onlyOwner() returns(bool) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    return true;
  }

  /** 
   * @dev Add mintable token to user verified owner.
   * @param _user         representation of minting user address.
   * @param _amount       representation of minting token quantities.
   * @param _atTime       representation of minting time of mintable
   */
  function mintable(address _user, uint256 _amount, uint256 _atTime) external onlyOwner() returns(bool) {
    Mint memory m = Mint({
      amount: _amount,
      atTime: _atTime
    });
    mints[_user].push(m);
    return true;
  }


  /**
   * @dev all minting token to user verified by owner.
   * @param _user         representation of minting user address.
   */
  function mint(address _user) external returns(bool) {

    for (uint n = 0; n < mints[_user].length; n++) {

      Mint memory m = mints[_user][n];

      require(isExecutable(m.atTime));

      balances[_user] = balances[_user].add(m.amount);
      totalSupply = totalSupply.add(m.amount);
      delete mints[_user][n];
    }
    return true;
  }

  /**
   * @dev changeable for token owner.
   * @param _newOwner representation of new owner address.
   */
  function changeOwner(address _newOwner) external onlyOwner() returns(bool) {
    require(_newOwner != 0x0);

    owner = _newOwner;

    return true;
  }


  /**
   * @dev constant return status whether time elapsed.
   * @param _executeTime  representation of time of executable.
   */
  function isExecutable(uint256 _executeTime) internal constant returns(bool) {
    if (block.timestamp < _executeTime) {
      return false;
    }
    return true;
  }

}