/**
 * @title SafeMath from https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 * @dev Math operations with safety checks that throw on error
 */
pragma solidity ^0.4.15;

import "./ERC20TokenStandard.sol";
import "./SafeMath.sol";

contract RICOToken is ERC20TokenStandard {
    
    using SafeMath for uint256;

    string public name;

    string public symbol;

    uint8 public decimals;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function RICOToken() {
        owner = msg.sender;
    }

    function init(string _name, string _symbol, uint8 _decimals) onlyOwner returns(bool) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        return true;
    }

    function mint(address _user, uint256 _amount) onlyOwner returns (bool) {
        balances[_user] = balances[_user].add(_amount);
        totalSupply = totalSupply.add(_amount);
        return true;
    }
}