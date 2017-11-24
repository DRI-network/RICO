pragma solidity ^0.4.18;

/// @title PoDStrategy - PoDStrategy contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract PoD {

  /**
   * Storage
   */

  string name;
  address owner;
  uint256 version;
  uint256 startTime;
  uint256 endTime;
  uint256 tokenPrice;
  uint256 proofOfDonationCapOfToken;
  uint256 proofOfDonationCapOfWei;

  enum Status {
    PoDDeployed,
    PoDInitialized,
    PoDStarted,
    PoDEnded
  }
  Status status;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function PoD() public {
    status = Status.PoDDeployed;
    owner = msg.sender;
  }

  function init(
    uint256 _proofOfDonationCapOfToken,
    uint256 _proofOfDonationCapOfWei
  )
  public onlyOwner() returns(bool) 
  {
    require(status == Status.PoDDeployed);
    proofOfDonationCapOfToken = _proofOfDonationCapOfToken;
    proofOfDonationCapOfWei = _proofOfDonationCapOfWei;
    status = Status.PoDInitialized;
    return true;
  }

  function getTokenPrice() public constant returns(uint256) {
    return tokenPrice;
  }

  /**
   * @dev changeable for token owner.
   * @param _newOwner set new owner of this contract.
   */
  function changeOwner(address _newOwner) external onlyOwner() returns(bool) {
    require(_newOwner != 0x0);

    owner = _newOwner;

    return true;
  }
}