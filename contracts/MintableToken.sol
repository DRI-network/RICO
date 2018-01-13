pragma solidity ^0.4.18;
import "./EIP20StandardToken.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is EIP20StandardToken, Ownable {
  using SafeMath for uint256;

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;
  bool public initialized = false;
  string public name;
  string public symbol;
  uint8 public decimals;
  address public projectOwner;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function MintableToken() public {}

  function init(string _name, string _symbol, uint8 _decimals, address _projectOwner) onlyOwner() public returns (bool) {
    require(!initialized);
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    projectOwner = _projectOwner;
    initialized = true;
    return initialized;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner() canMint() public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() canMint() public returns (bool) {
    require(msg.sender == projectOwner);
    mintingFinished = true;
    MintFinished();
    return true;
  }


  /**
   * @dev Emergency call for token transfer miss.
   */

  function tokenTransfer(address _token) public returns (bool) {
  
    require(msg.sender == projectOwner);

    EIP20StandardToken token = EIP20StandardToken(_token);

    uint balance = token.balanceOf(this);
    
    token.transfer(projectOwner, balance);
  }

  
}