pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


/**
 * @title VIOS Network Token
 * @dev 
 */
contract VIOS is ERC20, ERC20Detailed {
    using Roles for Roles.Role;
    Roles.Role private trustees;


    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(DECIMALS));
    uint256 public constant MAX_SUPPLY = 500000090 * (10 ** uint256(DECIMALS));
    uint256 public constant TOKENS_PER_BLOCK = 38059 * (10 ** uint256(DECIMALS - 4));

    string public name = "VIOS Network Token";
    string public symbol = "VIOS";
    uint8 public decimals = DECIMALS;
    uint8 public last_claim_block_number = 0;
    uint256 private _cap;


    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public {
    	_cap = MAX_SUPPLY;
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function isVIOSNetworkToken() public pure returns (bool) {
        return true;
    }
    function name() public view returns(string){
        return name;
    }
    function symbol() public view returns(string){
        return symbol;
    }
    function decimals() public view returns(uint8){
        return decimal;
    }

    /**
     * @return the cap for the token minting.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev Function to claim token balance
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function claimTokens(address to, uint256 value) public onlyMinter returns (bool) {
        require(trustees.has(msg.sender), "VIOS: does not have trustee role");
        require(totalSupply().add(value) <= _cap, "VIOS: cap exceeded");
        require(value <= balance, "VIOS: claim exceeds balance");
        uint256 current_block_number = 0;
        uint256 balance = TOKENS_PER_BLOCK * (current_block_number - last_claim_block_number);
        last_claim_block_number = current_block_number;
        _mint(to, value);
        return true;
    }

    function getCurrentBlockNumber() internal returns (uint256){
        return 0;
    }

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns(uint256){
        return totalSupply_;
    }
    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns(uint256){
        return balances[_owner];
    }
    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool){
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool){
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns(bool){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns(uint256){
        return allowed[_owner][_spender];
    }


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    // ********* the ANDREW functions ***********//
    uint256 public constant ELECTORATE_DIVISOR = 2;
    uint public constant VOTE_PROPOSAL_ADD_TRUSTEE = 0;
    uint public constant VOTE_PROPOSAL_REMOVE_TRUSTEE = 1;
    uint public constant DELEGATE_CHAIN_LIMIT = 10;
    uint256 public constant ELECTORATE_DIVISOR = 2;
       
    /**
     * @dev The Authority Node is owned by a multisig wallet that requires 21 signatures. These signers are the Authority Nodes.
     */
    ATN auth = ATN(); // TODO: insert multisig ATN address

    struct voter {
        uint256 credits; // credits is accumulated by delegation
        address delegate;   // the person that the voter chooses to delegate their vote to instead of voting themselves
    }
    // This is a type for a single proposal.
    struct Proposal {
        address trusteeNominee;
        uint yay; // the number of positive votes accumulated
        uint nay; // the number of negative votes accumulated
        uint authorizedYay;
        uint authorizedNay;
        bool authorized;
    }

    // A dynamically-sized array of 'Proposal' structs.
    Proposal[] public proposalsOption;

    // Declare state variable to store a 'ballotVoter' struct for every possible address.
    mapping(address => voter) public voters;

    /// New poll for choosing one of the 'trustees' nominees
    function doPoll(address[] trusteeNominees) {
        require(auth.isSubscribed(msg.sender) || proposalsOption.length == 0, 'ANDREW: poll in progress');
        // For every provided trustee, a new proposal object is created and added to the array's end.
        delete proposalsOption;
        delete voters;
        for (uint i = 0; i < trusteeNominees.length; i++) {
            // 'Proposal({...})' will create a temporary Proposal object 
            // 'proposalsOption.push(...)' will append it to the end of 'proposalsOption'.
            proposalsOption.push(Proposal({
                trusteeNominee: trusteeNominees[i],
                yay: 0,
                nay: 0,
                authorizedYay: 0,
                authorizedNay: 0,
                authorized: auth.isSubscribed(msg.sender)
            }));
        }
    }

    function doCreate(address voter, uint nominateeIndex) {
        // In case the argument of 'require' is evaluted to 'false',
        // it will terminate and revert all
        // state and VTHO balance changes. It is often
        // a good idea to use this in case the functions are
        // not called correctly. Keep in mind, however, that this
        // will currently also consume all of the provided gas
        // (this is planned to change in the future).
        if(auth.isSubscribed(voter)){

            // the auth can alternatively call doVote directly
            voters[voter].credits = 0;
            // the Authority address is not allowed to vote
        }
        else{
            require(voters[voter].credits == 0, 'ANDREW: ballot already exists');
            voters[voter].credits = balanceOf(voter);
        }
    }

    /// Delegate votes to the voter 'delegateAddr'.
    function doDelegate(address delegateAddr, uint nominateeIndex) {
        // assigns reference
        voter storage sender = voter[msg.sender];
        // The Authority address cannot delegate
        require(!auth.isSubscribed(msg.sender), 'ANDREW: Authority not allowed');
        // Self-delegation is not allowed.
        require(to != msg.sender, 'ANDREW: Self-delegation not allowed');
        require (sender.credits > -1, 'ANDREW: no credits');
        require (sender.credits > 0, 'ANDREW: no ballot');

        // Forward the delegation as long as
        // 'to' is delegated too.
        // In general, such loops can be very dangerous,
        // since if they run for too long, they might
        // need more gas than available inside a block.
        // In that scenario, no delegation is made
        // but in other situations, such loops might
        // cause a contract to get "stuck" completely.
        
        for (uint count = 0; voter[delegateAddr].delegate != address(0); count++;) {
            // We found a loop in the delegation, not allowed.
            require(delegateAddr != msg.sender, 'ANDREW: recursive delegation not allowed');
            require(count < DELEGATE_CHAIN_LIMIT, 'ANDREW: delegate chain limit reached');
            
            delegateAddr = voter[delegateAddr].delegate;
        }

        // Since 'sender' is a reference, this will modify 'sender.ballot[nominatedTrustee].credits'
        sender.delegate = delegateAddr;
        voter storage delegate = voter[delegateAddr];
        if(delegate.credits < 0) delegate.credits = 0; // allow delegate to resume voting if credits are furnished after her vote
        delegate.credits += sender.credits;
        sender.credits = -2;
    }

    function doAuthorize(uint nominateeIndex, uint yayOrNay){
        require(auth.isSubscribed(msg.sender), 'ANDREW: is not Authority');
        if(yayOrNay == 1) proposalsOption[nominateeIndex].authorizedYay = proposalsOption[nominateeIndex].yay;
        else if(yayOrNay == 0) proposalsOption[nominateeIndex].authorizedNay = proposalsOption[nominateeIndex].nay;
        proposalsOption[nominateeIndex].authorized = true;
    }

    function doRevokeAuthorize(uint nominateeIndex){
        require(auth.isSubscribed(msg.sender), 'ANDREW: is not Authority');
        proposalsOption[nominateeIndex].authorized = false;
        proposalsOption[nominateeIndex].authorizedYay = 0;
        proposalsOption[nominateeIndex].authorizedNay = 0;
    }

    /// Cast a vote or veto (including votes delegated to you) for nominatedTrustee
    function doVote(uint nominateeIndex, bool yay) {
        // If 'voter' or 'nominatedTrustee' are out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        
        voter storage sender = voter[msg.sender];
        require (sender.credits != -2, 'ANDREW: credits delegated');
        require (sender.credits != -1, 'ANDREW: vote already cast');
        require (sender.credits != 0, 'ANDREW: no ballot');
        if(yay) proposalsOption[nominateeIndex].yay += sender.delegateWeight;
        else proposalsOption[nominateeIndex].nay += sender.delegateWeight;
        sender.credits = -1;
    }

    /// @dev Attempts to assign the trustee
    function doExecute(uint nominateeIndex, bool yay) constant
            returns (bool)
    {
        require(proposalsOption[nominateeIndex].authorized, 'ANDREW: denied by Authority');
        uint tally = 0;
        if(yay) tally = proposalsOption[nominateeIndex].authorizedYay;
        else tally = proposalsOption[nominateeIndex].authorizedNay;
        if(tally > div (totalSupply(), ELECTORATE_DIVISOR) ){
            address trusteeNominee = proposalsOption[nominateeIndex].trusteeNominee;
            if(yay){
                trustees.add(nominatedTrustee);
            }
            else {
                trustees.remove(nominatedTrustee);                
            }
            delete proposalsOption;
            delete voters;
            return true;
        }
        // TODO: place penalty here
        return false;
    }
}
