pragma solidity ^0.5.0;

interface IATN {
    function isAuthorityNodeToken() external returns (bool);
    function isSubscribed(address _owner) external returns (bool);
}