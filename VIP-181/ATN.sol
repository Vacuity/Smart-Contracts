pragma solidity ^0.5.0;

import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC721/ERC721Full.sol';
import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC721/ERC721Mintable.sol';
import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC721/ERC721Burnable.sol';
import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/ownership/Ownable.sol';
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/access/Roles.sol";
import "./IATN.sol";

contract ATN is IATN, ERC721, ERC721Metadata, ERC721Mintable, ERC721Burnable, Ownable {
    constructor()
        ERC721Metadata("Authority Node", "ATN") 
        public
    {
        uint256 id = uint256(keccak256(abi.encodePacked("http://vios.network/o/AuthorityNode")));
        _mint(msg.sender, id);
        _setTokenURI(id, "http://vios.network/o/AuthorityNode");
    }

    function isAuthorityNodeToken() public pure returns (bool) {
        return true;
    }

    function isSubscribed(address _owner) public returns (bool)  {
        if (balanceOf(_owner) > 0) return true;
        return false;
    }   
}