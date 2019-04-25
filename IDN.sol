pragma solidity 0.4.24;

import 'zopenzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
import 'zopenzeppelin-solidity/contracts/token/ERC721/ERC721Mintable.sol';
import 'zopenzeppelin-solidity/contracts/token/ERC721/ERC721Burnable.sol';
import 'zopenzeppelin-solidity/contracts/token/ERC721/ERC721Enumerable.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import "openzeppelin-solidity/contracts/access/Roles.sol";

contract IDN is ERC721Full, ERC721Mintable, ERC721Burnable, ERC721Enumerable, Ownable {

    using Roles for Roles.Role;
    Roles.Role private admins;

    constructor(
        string name,
        string symbol,
        address[] _admins
    )
        ERC721Full(name, symbol)
        public
    {
        admins.addMany(_admins);
    }

    function create(
        address owner,
        string uri,
        string tokenUri
    )
        public
        returns (bool)
    {
        require(admins.has(msg.sender), "DOES_NOT_HAVE_ADMIN_ROLE");
        uint256 id = uint256(keccak256(abi.encodePacked(uri)));
        _mint(owner, id);
        _setTokenURI(id, tokenUri);
        return true;
    }

    function isSubscribed(address _owner) public returns (bool)  {
        if (balanceOf(_owner) > 1) return true;
        return false;
    }   
}