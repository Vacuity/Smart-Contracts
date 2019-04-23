contract IDN is ERC721Full {
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

    using Roles for Roles.Role;

    Roles.Role private admins;

    function createIDN(
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
}