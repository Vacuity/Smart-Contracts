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
    uint256 public constant ELECTORATE_DIVISOR = 2;

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
       
    /**
     * @dev The Authority Node is owned by a multisig wallet that requires 21 signatures. These signers are the Authority Nodes.
     */
    ATN auth = ATN(); // TODO: insert multisig ATN address

    struct ballot {
        uint256 credits; // credits is accumulated by delegation
        uint256 voteSpent;  // amount of credits spent
        address delegate; // the person that the voter chooses to deleg    
        bool authorized;
        uint proposal;
    }

    // This will declare a new complex data type, which we can use to represent individual voters.
    struct voter {
        mapping(address => ballot) public ballots;
    }

    // Declare state variable to store a 'ballotVoter' struct for every possible address.
    mapping(address => voter) public voters;

    function doCreate(address voter, address nominatedTrustee) {
        // In case the argument of 'require' is evaluted to 'false',
        // it will terminate and revert all
        // state and VTHO balance changes. It is often
        // a good idea to use this in case the functions are
        // not called correctly. Keep in mind, however, that this
        // will currently also consume all of the provided gas
        // (this is planned to change in the future).
        if(auth.isSubscribed(voter)){

            // the auth can alternatively call doVote directly
            voters[voter].ballots[nominatedTrustee].credits = 0;
            // the Authority address is not allowed to vote
        }
        else{
            require(voters[voter].ballots[nominatedTrustee].credits == 0, 'VIOS: ballot already exists');
            voters[voter].ballots[nominatedTrustee].credits = balanceOf(voter);
        }
    }

    /// Delegate votes to the voter 'delegateAddr'.
    function doDelegate(address delegateAddr, address nominatedTrustee, uint256 voteCount) {
        // assigns reference
        voter storage sender = voter[msg.sender];
        // The Authority address cannot delegate
        require(!auth.isSubscribed(msg.sender), 'VIOS: Authority not allowed');
        // Self-delegation is not allowed.
        require(to != msg.sender, 'VIOS: Self-delegation not allowed');
        require(sender.ballots[nominatedTrustee].voteCount + voteCount <= sender.ballots[nominatedTrustee].credits, 'VIOS: insufficient credits');

        // Forward the delegation as long as
        // 'to' is delegated too.
        // In general, such loops can be very dangerous,
        // since if they run for too long, they might
        // need more gas than available inside a block.
        // In that scenario, no delegation is made
        // but in other situations, such loops might
        // cause a contract to get "stuck" completely.
        uint count = 0;
        for (; voter[delegateAddr].ballots[nominatedTrustee].delegate != address(0); delegateAddr = voter[delegateAddr].ballots[nominatedTrustee].delegate;) {
            // We found a loop in the delegation, not allowed.
            require(delegateAddr != msg.sender, 'VIOS: recursive delegation not allowed');
            require(count < DELEGATE_CHAIN_LIMIT, 'VIOS: delegate chain limit reached');
            count++;
        }

        // Since 'sender' is a reference, this will modify 'sender.ballot[nominatedTrustee].voteSpent'
        sender.ballots[nominatedTrustee].voteSpent = true;
        sender.ballots[nominatedTrustee].delegate = delegateAddr;
        voter storage delegate = voter[delegateAddr];
        delegate.ballots[nominatedTrustee].credits += sender.credits;
    }

    /// Cast a vote or veto (including votes delegated to you) for nominatedTrustee
    function doVote(uint nominatedTrustee, unit proposal, uint256 voteCount) {
        // If 'voter' or 'nominatedTrustee' are out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        voter storage sender = voter[msg.sender];
        if(auth.isSubscribed(msg.sender)){
            sender.ballots[nominatedTrustee].authorized = true;
            sender.ballots[nominatedTrustee].proposal = proposal;
        }
        else {
            require(sender.ballots[nominatedTrustee].voteCount + voteCount <= sender.ballots[nominatedTrustee].credits, 'VIOS: insufficient credits');
            sender.ballots[nominatedTrustee].voteCount += voteCount;
            sender.ballots[nominatedTrustee].proposal = proposal;
        }
    }

    /// @dev Attempts to assign the trustee
    function doExecute(address nominatedTrustee, uint proposal) constant
            returns (bool)
    {
        uint tally = 0;
        bool authorized;
        for (uint idx = 0; idx < voter.length; idx++) {
            if(voters[idx].ballots[nominatedTrustee].proposal != proposal) continue;
            tally += voters[idx].ballots[nominatedTrustee].voteCount;
            if(voter[idx].ballots[nominatedTrustee].authorized) authorized = true;
        }
        require(authorized, 'VIOS: denied by Authority');
        if(proposal == VOTE_PROPOSAL_ADD_TRUSTEE && tally > div (totalSupply(), ELECTORATE_DIVISOR) ){
            trustees.add(nominatedTrustee);
            return true;
        }
        if(proposal == VOTE_PROPOSAL_REMOVE_TRUSTEE && tally > div (totalSupply(), ELECTORATE_DIVISOR) ){
            trustees.remove(nominatedTrustee);
            return true;
        }
        // TODO: place penalty here
        return false;
    }

    function doBurn(address nominatedTrustee) constant returns (bool){
        require(auth.isSubscribed(msg.sender), 'VIOS: must be Authority');
        for (uint idx = 0; idx < voter.length; idx++) {
            delete voter[idx].ballots[nominatedTrustee];
        }
        return true;
    }

}
