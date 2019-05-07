pragma solidity ^0.5.0;

import '/Users/shermanmonroe/Documents/GitHub/andrew/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
import '/Users/shermanmonroe/Documents/GitHub/andrew/openzeppelin-solidity/contracts/token/ERC721/ERC721Mintable.sol';
import '/Users/shermanmonroe/Documents/GitHub/andrew/openzeppelin-solidity/contracts/token/ERC721/ERC721Burnable.sol';
import '/Users/shermanmonroe/Documents/GitHub/andrew/openzeppelin-solidity/contracts/ownership/Ownable.sol';
import "./NodeAdmin.sol";

contract IDN is ERC721Enumerable, ERC721Metadata, ERC721Mintable, ERC721Burnable, Ownable, NodeAdmin {
    constructor()
        ERC721Metadata("Identity Node", "IDN")  
        public
    {
    }

    function createNode(address owner, string memory uri, string memory tokenUri) public onlyAdmin returns (uint256)
    {
        uint256 id = uint256(keccak256(abi.encodePacked(uri)));
        _mint(owner, id);
        _setTokenURI(id, tokenUri);
        return id;
    }
    
    function revokeNode(address owner, uint256 id) public onlyAdmin returns (bool)
    {
        _burn(owner, id);
        return true;
    }

    function isIdentityNodeToken() public pure returns (bool) {
        return true;
    }

    function isSubscribed(address _owner) public returns (bool)  {
        if (balanceOf(_owner) > 0) return true;
        return false;
    }   

    function destroy() public {
        require(isSubscribed(msg.sender), 'IDN: is not Authority');
        selfdestruct(msg.sender);
    }
}