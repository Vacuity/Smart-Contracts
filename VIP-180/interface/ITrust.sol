pragma solidity ^0.5.0;
import "./IATN.sol";

interface ITrust {
    function isTrustee(address account) external view returns (bool) ;

    function renounceTrust() external ;
    
    function getAuthority() external returns (IATN);
}
