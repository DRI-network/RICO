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

    modifier onlyOwner() {
        require(msg.sender == owner);
        /// Only owner is allowed to proceed
        _;
    }

    /**
     * constructorÏ
     * @dev define owner when this contract deployed.
     */
    function RICOToken() {
        owner = msg.sender;
    }

    /** 
     * @dev initialize token meta Data implement for ERC-20 Token Standard Format.
     * @param _name         represent a Token name.
     * @param _symbol       represent a Token symbol.
     * @param _decimals     represent a Token decimals.
     */

    function init(string _name, string _symbol, uint8 _decimals) onlyOwner() returns(bool) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        return true;
    }

    /** 
     * @dev minting token to user verified owner.
     * @param _user         represent a minting user address.
     * @param _amount       represent a minting token quantities.
     */
    function mint(address _user, uint256 _amount) onlyOwner() returns(bool) {
        balances[_user] = balances[_user].add(_amount);
        totalSupply = totalSupply.add(_amount);
        return true;
    }
}