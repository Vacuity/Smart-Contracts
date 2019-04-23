contract IDN is ERC721Full {
    constructor(
        string name,
        string symbol,
    )
        ERC721Full(name, symbol)
        public
    {}

    function createIDN(
        address owner,
        string uri,
        string tokenUri
    )
        public
        returns (bool)
    {

        uint256 id = uint256(keccak256(abi.encodePacked(uri)));
        _mint(owner, id);
        _setTokenURI(id, tokenUri);
        return true;
    }
}