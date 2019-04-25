pragma solidity ^0.5.2;

import 'zopenzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
import 'zopenzeppelin-solidity/contracts/token/ERC721/ERC721Mintable.sol';
import 'zopenzeppelin-solidity/contracts/token/ERC721/ERC721Burnable.sol';
import 'zopenzeppelin-solidity/contracts/token/ERC721/ERC721Enumerable.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import "openzeppelin-solidity/contracts/access/Roles.sol";

contract IDN is ERC721Full, ERC721Mintable, ERC721Burnable, ERC721Enumerable, Ownable {

    using Roles for Roles.Role;
    Roles.Role private admins;

    string public constant name_ = "Identity Node";
    string public constant symbol_ = "IDN";

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

    function purchase(id) public payable {
        require(msg.value == getPrice(id));
        _mint(msg.sender, totalSupply());
    }

    function getPrice(uint256 id) public returns (uint256){
        return 0;
    }

    function create(
        address owner,
        string uri,
        string tokenUri
    )
        public
        returns (bool)
    {
        require(admins.has(msg.sender), "IDN: does not have admin role");
        uint256 id = uint256(keccak256(abi.encodePacked(uri)));
        _mint(owner, id);
        _setTokenURI(id, tokenUri);
        return true;
    }

    function isSubscribed(address _owner) public returns (bool)  {
        if (balanceOf(_owner) > 1) return true;
        return false;
    }   


    function name() public view returns(string)
    function symbol() public view returns(string)
    function totalSupply() public view returns(uint256)
    function balanceOf(address _owner) public view returns(uint256)
    function ownerOf(uint256 _tokenId) public view returns(address)
    function transferFrom(address _from, address _to, uint256 _tokenId) public
    function approve(address _spender, uint256 _tokenId) public
    function getApproved(uint256 _tokenId) public view returns(address)
    function setApprovalForAll(address _operator, bool _approved) public
    function isApprovedForAll(address _owner, address _operator) public view returns(bool)
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId)
    event Approval(address indexed _owner, address indexed _spender, uint256 indexed _tokenId)
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved)

    
}