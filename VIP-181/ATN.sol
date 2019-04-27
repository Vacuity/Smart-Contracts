pragma solidity ^0.5.0;

import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC721/ERC721Full.sol';
import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC721/ERC721Mintable.sol';
import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC721/ERC721Burnable.sol';
import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC721/ERC721Enumerable.sol';
import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/ownership/Ownable.sol';
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/access/Roles.sol";

contract ATN is ERC721Full, ERC721Mintable, ERC721Burnable, Ownable {

    using Roles for Roles.Role;
    Roles.Role private admin;

    string public constant name_ = "Identity Node";
    string public constant symbol_ = "IDN";

    constructor(
        string memory name,
        string memory symbol
    )
        ERC721Full(name, symbol)
        public
    {
        Roles.add(admin, msg.sender);
        create(msg.sender, "http://vios.network/o/AuthorityNode", "http://vios.network/o/AuthorityNode");
    }

    function purchase(uint256 id) public payable {
        require(msg.value == getPrice(id));
        _mint(msg.sender, totalSupply());
    }

    function getPrice(uint256 id) public returns (uint256){
        return 0;
    }

    function create(
        address owner,
        string memory uri,
        string memory tokenUri
    )
        public
        returns (bool)
    {
        require(Roles.has(admin, msg.sender), "IDN: does not have admin role");
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