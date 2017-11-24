pragma solidity ^0.4.18;
import "../PoD.sol";
/// @title PoDStrategy - PoDStrategy contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract DutchAuctionPoD is PoD {

    function DutchAuctionPoD() {
        auction.init(this, ts.proofOfDonationCapOfToken, 2 ether, 524880000, 3);

    }

}
