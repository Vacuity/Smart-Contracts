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
    Roles.Role public trustees;

    /**
     * @dev The Authority Node is owned by a multisig wallet that requires 21 signatures. These signers are the Authority Nodes.
     */
    ATN public auth = ATN(); // TODO: insert ATN address

    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(DECIMALS));
    uint256 public constant MAX_SUPPLY = 500000090 * (10 ** uint256(DECIMALS));
    uint256 public constant TOKENS_PER_BLOCK = 38059 * (10 ** uint256(DECIMALS - 4));

    string public name = "VIOS Network Token";
    string public symbol = "VIOS";
    uint8 public decimals = DECIMALS;
    uint8 public last_claim_block_number = 0;
    uint256 public _cap;


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
    constructor (ATN _auth) public {
    	_cap = MAX_SUPPLY;
        auth = _auth;
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
        require(trustees.has(msg.sender), "VIOS: sender does not have trustee role");
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
    uint public constant VOTE_PROPOSAL_ADD_TRUSTEE = 0;
    uint public constant VOTE_PROPOSAL_REMOVE_TRUSTEE = 1;
    uint public constant BALLOT_STATUS_NONE = 0;
    uint public constant BALLOT_STATUS_DEFAULT = 1;
    uint public constant BALLOT_STATUS_VOTED = 2;
    uint public constant BALLOT_STATUS_DELEGATED = 3;
    uint public constant DELEGATE_CHAIN_LIMIT = 10;
    uint public constant  SET_AUTH_WAIT = 1000000000000; //TODO
    struct voter {
        uint256 credits; // credits is accumulated by delegation
        uint status;
        address delegate;   // the person that the voter chooses to delegate their vote to instead of voting themselves
    }
    // This is a type for a single proposal.
    struct Proposal {
        address trusteeNominee;
        uint yay; // the number of positive votes accumulated
        uint nay; // the number of negative votes accumulated
        uint type;
        uint authorizedYay;
        uint authorizedNay;
        bool authorized;
    }

    uint public majorityDivisor = 2;

    // A dynamically-sized array of 'Proposal' structs.
    Proposal[] public proposals;

    // Declare state variable to store a 'ballotVoter' struct for every possible address.
    mapping(address => voter) public voters;

    function setAuth(ATN newAuth){
        require(auth.isSubscribed(msg.sender), 'ANDREW: sender is not Authority');
        require(newATN.isSubscribed(msg.sender), 'ANDREW: destination Authority not found');
        auth = newAuth;
    }

    uint public set_auth_block_number; // the Authority has 8 hours to revert the setAuth change
    function setAuthByCommunity(uint nominateeIndex){
        // TODO: attach a high price so that this function does not get spammed
        require(trustees.has(msg.sender), "ANDREW: sender does not have trustee role");
        require(set_auth_block_number == 0, 'ANDREW: set auth in progress');
        set_auth_block_number = current_block_number + SET_AUTH_WAIT;
    }

    function executeByCommunity(uint nominateeIndex){
        require(trustees.has(proposals[nominateeIndex].trusteeNominee), "ANDREW: does not have trustee role");
        require(current_block_number >= set_auth_block_number, 'ANDREW: set auth in progress');
        if(proposals[nominateeIndex].yay > div (totalSupply(), DIVISOR_SIMPLE_MAJORITY) ){
            auth = ATN(proposals[nominateeIndex].trusteeNominee);
            delete proposals;
            delete voters;
            set_auth_block_number = 0;
        }        
    }

    /// Opens new poll for choosing one of the 'trustees' nominees
    function open(address[] trusteeNominees, uint[] types, uint _majorityDivisor) {
        require(auth.isSubscribed(msg.sender) || proposals.length == 0, 'ANDREW: poll in progress');
        require(_majorityDivisor > 5, 'ANDREW: requires 20% participation or more');
        require(_majorityDivisor < 2, 'ANDREW: requires 50% participation or less');
        require(trusteeNominees.length == types.length, 'ANDREW: invalid proposal');
        // For every provided trustee, a new proposal object is created and added to the array's end.
        delete proposals;
        delete voters;
        majorityDivisor = _majorityDivisor;
        for (uint i = 0; i < trusteeNominees.length; i++) {
            // 'Proposal({...})' will create a temporary Proposal object 
            // 'proposals.push(...)' will append it to the end of 'proposals'.
            require(type[i] == VOTE_PROPOSAL_REMOVE_TRUSTEE || type[i] = VOTE_PROPOSAL_ADD_TRUSTEE, 'ANDREW: invalid proposal');
            proposals.push(Proposal({
                trusteeNominee: trusteeNominees[i],
                yay: 0,
                nay: 0,
                type: type[i],
                authorizedYay: 0,
                authorizedNay: 0,
                authorized: false
            }));
        }
    }

    function close(){
        require(auth.isSubscribed(msg.sender), 'ANDREW: denied by Authority');
        delete proposals;
        delete voters;
        majorityDivisor = 2;
    }

    function issueBallot(address voter) {
        // In case the argument of 'require' is evaluted to 'false',
        // it will terminate and revert all
        // state and VTHO balance changes. It is often
        // a good idea to use this in case the functions are
        // not called correctly. Keep in mind, however, that this
        // will currently also consume all of the provided gas
        // (this is planned to change in the future).
        if(auth.isSubscribed(voter)){

            // the auth can alternatively call doVote directly
            voters[voter].credits = BALLOT_STATUS_NONE;
            // the Authority address is not allowed to vote
        }
        else{
            require(voters[voter].status == BALLOT_STATUS_NONE, 'ANDREW: ballot already exists');
            voters[voter].credits = balanceOf(voter);
            voters[voter].status = BALLOT_STATUS_DEFAULT;
        }
    }

    /// Delegate votes to the voter 'delegateAddr'.
    function delegate(address delegateAddr) {
        // assigns reference
        // The Authority address cannot delegate
        require(!auth.isSubscribed(msg.sender), 'ANDREW: Authority not allowed');
        // Self-delegation is not allowed.
        require(to != msg.sender, 'ANDREW: self-delegation not allowed');
        voter storage sender = voter[msg.sender];
        require (sender.status != BALLOT_STATUS_DELEGATED, 'ANDREW: credits delegated');
        require (sender.status != BALLOT_STATUS_VOTED, 'ANDREW: vote already cast');
        require (sender.status != BALLOT_STATUS_NONE, 'ANDREW: no ballot');

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
            require(delegateAddr != msg.sender, 'ANDREW: indirect self-delegation not allowed');
            require(count < DELEGATE_CHAIN_LIMIT, 'ANDREW: delegate chain limit reached');
            
            delegateAddr = voter[delegateAddr].delegate;
        }

        // Since 'sender' is a reference, this will modify 'sender.ballot[nominatedTrustee].credits'
        sender.delegate = delegateAddr;
        voter storage delegate = voter[delegateAddr];
        if(delegate.credits == 0) delegate.credits = 0; // allow delegate to resume voting if credits are furnished after her vote
        delegate.credits += sender.credits;
        sender.status = BALLOT_STATUS_DELEGATED;
    }

    function authorize(uint nominateeIndex, uint yayOrNay){
        uint yay = proposals[nominateeIndex].yay;
        uint nay = proposals[nominateeIndex].nay;
        require(auth.isSubscribed(msg.sender), 'ANDREW: sender is not Authority');
        require (yayOrNay < 0 || yayOrNay > 1, 'ANDREW: invalid input'); 
        if(yayOrNay == 1) proposals[nominateeIndex].authorizedYay = yay;
        else if(yayOrNay == 0) proposals[nominateeIndex].authorizedNay = nay;
        proposals[nominateeIndex].authorized = true;
    }

    function revokeAuthorize(uint nominateeIndex){
        require(auth.isSubscribed(msg.sender), 'ANDREW: sender is not Authority');
        proposals[nominateeIndex].authorized = false;
        proposals[nominateeIndex].authorizedYay = 0;
        proposals[nominateeIndex].authorizedNay = 0;
    }

    /// Cast a vote or veto (including votes delegated to you) for nominatedTrustee
    function vote(uint nominateeIndex, uint yayOrNay, uint type) {
        // If 'voter' or 'nominatedTrustee' are out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        
        voter storage sender = voter[msg.sender];
        require (sender.status != BALLOT_STATUS_DELEGATED, 'ANDREW: credits delegated');
        require (sender.status != BALLOT_STATUS_VOTED, 'ANDREW: vote already cast');
        require (sender.status != BALLOT_STATUS_NONE, 'ANDREW: no ballot');
        require (proposals[nominateeIndex].type != type, 'ANDREW: type not found'); // requiring 'type' ensures the sender is aware of the proposal type
        require (yayOrNay < 0 || yayOrNay > 1, 'ANDREW: invalid input'); 
        if(yayOrNay == 1) proposals[nominateeIndex].yay += sender.delegateWeight;
        else if(yayOrNay == 0) proposals[nominateeIndex].nay += sender.delegateWeight;
        sender.status = BALLOT_STATUS_VOTED;
    }

    /// @dev Attempts to assign the trustee
    function execute(uint nominateeIndex) constant
            returns (bool)
    {
        Proposal proposal = proposals[nominateeIndex];
        require(proposal.authorized, 'ANDREW: denied by Authority');
        uint total = proposal.authorizedYay;
        total += proposal.authorizedNay;
        if(total >= div (totalSupply(), uint256(majorityDivisor)) && proposal.authorizedYay > proposal.authorizedNay){
            if(proposal.type == VOTE_PROPOSAL_ADD_TRUSTEE){
                trustees.add(proposal.trusteeNominee);
            }
            else if(proposal.type == VOTE_PROPOSAL_REMOVE_TRUSTEE) {
                trustees.remove(proposal.trusteeNominee);                
            }
            delete proposals;
            delete voters;
            majorityDivisor = 2;
            return true;
        }
        // TODO: place penalty here
        return false;
    }

}
