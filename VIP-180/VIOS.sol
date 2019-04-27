pragma solidity ^0.5.0;

//import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC20/ERC20Capped.sol";
//import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC20/ERC20Detailed.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/access/Roles.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/math/SafeMath.sol";
import "./ATN.sol";


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;


   /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns(uint256){
        return _totalSupply;
    }
    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns(uint256){
        return _balances[owner];
    }
    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool){
        require(to != address(0));
        require(value <= _balances[msg.sender]);

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        //emit Transfer(msg.sender, _to, _value);
        return true;
    }
    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns(bool){
        require(to != address(0));
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);

        _balances[from] = _balances[_from].sub(value);
        _balances[to] = _balances[_to].add(_value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        //emit Transfer(_from, _to, _value);
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
    function approve(address spender, uint256 value) public returns(bool){
        _allowed[msg.sender][spender] = value;
        //emit Approval(msg.sender, _spender, _value);
        return true;
    }
    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns(uint256){
        return _allowed[owner][spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses.
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "ERC20: transfer to the zero address");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        //emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        //emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        //emit Transfer(account, address(0), value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowed[owner][spender] = value;
        //emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

contract Trust {
    using Roles for Roles.Role;

    event TrusteeAdded(address indexed account);
    event TrusteeRemoved(address indexed account);

    Roles.Role private _trustees;
    address[] keys;

    constructor () internal {
        _addTrustee(msg.sender);
    }

    modifier trusteesOnly() {
        require(isTrustee(msg.sender), "Trust: caller does not have the trustee role");
        _;
    }

    function isTrustee(address account) public view returns (bool) {
        return _trustees.has(account);
    }

    function renounceTrust() public {
        _removeTrustee(msg.sender);
    }

    function _addTrustee(address account) internal {
        require(account != address(0), 'Trust: zero address not allowed');
        _trustees.add(account);
        emit TrusteeAdded(account);
    }

    function _removeTrustee(address account) internal {
        _trustees.remove(account);
        emit TrusteeRemoved(account);
    }
}

/**
 * @title Escrow
 * @dev Token dispensary with a token cap.
 */
contract Escrow is ERC20, Trust {
    uint256 private _cap;

    constructor (uint256 cap) public {
        require(cap > 0, "Escrow: cap is 0");
        _cap = cap;
    }

    /**
     * @return the cap for the token minting.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap, "Escrow: cap exceeded");
        super._mint(account, value);
    }
}


/**
 * @title VIOS Network Token
 * @dev 
 */
contract VIOS is Escrow, ERC20Detailed {
    /**
     * @dev The Authority Node is owned by a multisig wallet that requires 21 signatures. These signers are the Authority Nodes.
     */
    ATN private auth = ATN(address(0)); // TODO: insert ATN address

    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(DECIMALS));
    uint256 public constant TEST_INITIAL_SUPPLY = 10 * (10 ** uint256(DECIMALS));
    uint256 public constant MAX_SUPPLY = 500000090 * (10 ** uint256(DECIMALS));
    uint256 public constant TOKENS_PER_SECOND = 38059 * (10 ** uint256(DECIMALS - 5));

    uint256 public last_claim_timestamp = 0;

    //function getTrustees() public returns (Roles.Role memory){
    //    return trustees;
    //}

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor (address _auth) 
    Escrow(MAX_SUPPLY) 
    ERC20Detailed("VIOS Network Token", "VIOS", DECIMALS) 
    public {
        auth = ATN(_auth);
        super._mint(msg.sender, INITIAL_SUPPLY);
        _removeTrustee(msg.sender); // caller was added to trustees when trustee role was created 
        last_claim_timestamp = now;
    }
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function isVIOSNetworkToken() public pure returns (bool) {
        return true;
    }

    /**
     * @dev Function to claim token balance
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function withdrawFromEscrow(uint256 value) public trusteesOnly returns (bool) {
        uint256 balance = TOKENS_PER_SECOND * (now - last_claim_timestamp);
        require(value <= balance, "VIOS: claim exceeds escrow");
        super._mint(msg.sender, value);
        last_claim_timestamp = now;
        return true;
    }
    
    function withdrawEscrow() public trusteesOnly returns (bool){
        return withdrawFromEscrow(escrowBalance());
    }

    function escrowBalance() public returns (uint256){
        return TOKENS_PER_SECOND * (now - last_claim_timestamp);
    }
    
    function balance() public returns (uint256) {
        return balanceOf(msg.sender);
    }

    // ********* the ANDREW functions ***********//
    uint public constant VOTE_PROPOSAL_ADD_TRUSTEE = 1;
    uint public constant VOTE_PROPOSAL_REMOVE_TRUSTEE = 2;
    uint public constant BALLOT_STATUS_NONE = 0;
    uint public constant BALLOT_STATUS_ACTIVE = 1;
    uint public constant DELEGATE_CHAIN_LIMIT = 10;
    uint public constant  SET_AUTH_WAIT = 28800  * (10 ** uint256(DECIMALS)); // the Authority has 8 hours to revert the setAuth change
    struct voter {
        uint status;
        address delegate;   // the person that the voter chooses to delegate their vote to instead of voting themselves
        bool isDelegate;
    }
    // This is a type for a single proposal.
    struct proposal {
        address trusteeNominee;
        uint yay; // the number of positive votes accumulated
        uint nay; // the number of negative votes accumulated
        uint proposalType;
        uint authorizedYay;
        uint authorizedNay;
        bool authorized;
    }

    uint public majorityDivisor = 2;

    // A dynamically-sized array of 'proposal' structs.
    proposal[] public proposals;

    // Declare state variable to store a 'ballotVoter' struct for every possible address.
    mapping(address => voter) public voters;
    mapping(address => uint256) public credits; // credits are accumulated by delegation
    uint public deposit;
    address public sponsorAddr;

    address[] delegated;
    address[] voted;    
    uint public auth_timestamp; 
    uint public proposal_fee;

    function setProposalFee(uint amount){
        require(auth.isSubscribed(msg.sender), 'ANDREW: caller is not Authority');
        proposal_fee = amount;
    }

    function setAuth(ATN newAuth) private {
        require(auth.isSubscribed(msg.sender), 'ANDREW: caller is not Authority');
        require(newAuth.isSubscribed(msg.sender), 'ANDREW: destination Authority not found');
        auth = newAuth;
    }

    function setAuthByCommunity(uint nominateeIndex) public {
        // TODO: attach a high price so that this function does not get spammed
        require(isTrustee(msg.sender), "ANDREW: caller does not have trustee role");
        require(auth_timestamp == 0, 'ANDREW: set auth in progress');
        auth_timestamp = now + SET_AUTH_WAIT;
    }
    
    function executeByCommunity(uint nominateeIndex) public {
        require(isTrustee(proposals[nominateeIndex].trusteeNominee), "ANDREW: does not have trustee role");
        require(now >= auth_timestamp, 'ANDREW: set auth in progress');
        if(SafeMath.add(proposals[nominateeIndex].authorizedYay, proposals[nominateeIndex].authorizedNay) >= SafeMath.div (totalSupply(), uint256(majorityDivisor)) && proposals[nominateeIndex].authorizedYay > proposals[nominateeIndex].authorizedNay){
            auth = ATN(proposals[nominateeIndex].trusteeNominee);
            delete proposals;
            delete delegated;
            delete voted;
            majorityDivisor = 2;
            auth_timestamp = 0;
        }        
    }

    // Opens new poll for choosing one of the 'trustees' nominees
    function open(address[] memory trusteeNominees, uint[] memory proposalTypes, uint _majorityDivisor, uint amount) public {
        require(auth.isSubscribed(msg.sender) || proposals.length == 0, 'ANDREW: poll in progress');
        require(amount >= proposal_fee, 'ANDREW: requires ' + proposal_fee + ' ' + symbol());
        require(_majorityDivisor <= 5, 'ANDREW: requires 20% participation or more');
        require(_majorityDivisor >= 2, 'ANDREW: requires 50% participation or less');
        require(trusteeNominees.length == proposalTypes.length, 'ANDREW: invalid proposal');

        deposit = amount;
        _transfer(msg.sender, address(this), amount);
        sponsorAddr = msg.sender;

        // For every provided trustee, a new proposal object is created and added to the array's end.
        delete proposals;
        delete delegated;
        delete voted;
        majorityDivisor = _majorityDivisor;
        for (uint i = 0; i < trusteeNominees.length; i++) {
            // 'proposal({...})' will create a temporary proposal object 
            // 'proposals.push(...)' will append it to the end of 'proposals'.
            require(proposalTypes[i] == VOTE_PROPOSAL_REMOVE_TRUSTEE || proposalTypes[i] == VOTE_PROPOSAL_ADD_TRUSTEE, 'ANDREW: invalid proposal');
            proposals.push(proposal({
                trusteeNominee: trusteeNominees[i],
                yay: 0,
                nay: 0,
                proposalType: proposalTypes[i],
                authorizedYay: 0,
                authorizedNay: 0,
                authorized: false
            }));
        }
    }

    function close() public {
        require(auth.isSubscribed(msg.sender), 'ANDREW: caller is not Authority');
        if(deposit > 0){
            bool refund = false;
            for (uint i = 0; i < proposals.length; i++) {
                if(proposals[i].authorized) refund = true;
            }
            if(refund){
                _transfer(address(this), sponsorAddr, deposit); // refund the deposit
            }
            else {
                _transfer(address(this), msg.sender, deposit); // confiscate the deposit
            }
        }
        delete proposals;
        delete delegated;
        delete voted;
        majorityDivisor = 2;
        deposit = 0;
        sponsorAddr = address(0);
        auth_timestamp = 0;
        proposal_fee = 0;
    }

    function claimBallot(uint256 amount) public {
        require(proposals.length != 0, 'ANDREW: poll closed');
        if(auth.isSubscribed(msg.sender)){
            // the Authority address is not allowed to vote
            // the auth can alternatively call doVote directly
            voters[msg.sender].status = BALLOT_STATUS_NONE;
        }
        else{
            uint256 c = credits[msg.sender];
            if(c > 0){
                credits[msg.sender] = 0;
                _transfer(address(this), msg.sender, c); // refund the leftover credits
            }
            voter storage sender = voters[msg.sender];
            require(sender.status != BALLOT_STATUS_ACTIVE, 'ANDREW: ballot already exists');
            require(amount <= balanceOf(msg.sender), 'ANDREW: insufficient funds');
            _transfer(msg.sender, address(this), amount);
            credits[msg.sender] = amount;
            sender.status = BALLOT_STATUS_ACTIVE;
        }
    }
    
    function claimCredits() public returns (bool){
        require(proposals.length == 0, 'ANDREW: poll in progress');
        _transfer(address(this), msg.sender, credits[msg.sender]);
        delete credits[msg.sender];
    }

    /// Delegate votes to the voter 'delegateAddr'.
    function delegate(address delegateAddr) public {
        // assigns reference
        // The Authority address cannot delegate
        require(!auth.isSubscribed(msg.sender), 'ANDREW: Authority not allowed');
        // Self-delegation is not allowed.
        require(delegateAddr != msg.sender, 'ANDREW: self-delegation not allowed');
        voter storage sender = voters[msg.sender];
        require (getIndex(delegated, msg.sender) == -1, 'ANDREW: credits delegated');
        require (getIndex(voted, msg.sender) == -1, 'ANDREW: vote already cast');
        require (sender.status != BALLOT_STATUS_NONE, 'ANDREW: no ballot');

        // Forward the delegation as long as
        // 'to' is delegated too.
        // In general, such loops can be very dangerous,
        // since if they run for too long, they might
        // need more gas than available inside a block.
        // In that scenario, no delegation is made
        // but in other situations, such loops might
        // cause a contract to get "stuck" completely.
        
        for (uint count = 0; voters[delegateAddr].delegate != address(0); count++) {
            // We found a loop in the delegation, not allowed.
            require(delegateAddr != msg.sender, 'ANDREW: indirect self-delegation not allowed');
            require(count < DELEGATE_CHAIN_LIMIT, 'ANDREW: delegate chain limit reached');
            
            delegateAddr = voters[delegateAddr].delegate;
        }
        
        require (voters[delegateAddr].status != BALLOT_STATUS_NONE, 'ANDREW: delegate has no ballot');
        require (getIndex(delegated, delegateAddr) == -1, 'ANDREW: delegate credits delegated'); // if delegate has made made their choice, and does not return to the poll to check their credit balance, users who send credits afterwards will effectively waste those credits
        require (getIndex(voted, delegateAddr) == -1, 'ANDREW: delegate vote already cast');

        // Since 'sender' is a reference, this will modify 'sender.ballot[nominatedTrustee].credits'
        sender.delegate = delegateAddr;
        voters[delegateAddr].isDelegate = true;
        credits[delegateAddr] += credits[msg.sender];
        delegated.push(msg.sender);
        delete voters[msg.sender];
    }

    function authorize(uint nominateeIndex, uint yayOrNay) public {
        uint yay = proposals[nominateeIndex].yay;
        uint nay = proposals[nominateeIndex].nay;
        require(auth.isSubscribed(msg.sender), 'ANDREW: caller is not Authority');
        require (yayOrNay == 0 || yayOrNay == 1, 'ANDREW: invalid input'); 
        if(yayOrNay == 1) proposals[nominateeIndex].authorizedYay = yay;
        else if(yayOrNay == 0) proposals[nominateeIndex].authorizedNay = nay;
        proposals[nominateeIndex].authorized = true;
    }

    function revokeAuthorize(uint nominateeIndex) public {
        require(auth.isSubscribed(msg.sender), 'ANDREW: caller is not Authority');
        proposals[nominateeIndex].authorized = false;
        proposals[nominateeIndex].authorizedYay = 0;
        proposals[nominateeIndex].authorizedNay = 0;
    }

    /// Cast a vote or veto (including votes delegated to you) for nominatedTrustee
    function vote(uint nominateeIndex, uint yayOrNay, uint proposalType) public {
        // If 'voter' or 'nominatedTrustee' are out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        
        voter memory sender = voters[msg.sender];
        require (getIndex(delegated, msg.sender) == -1, 'ANDREW: credits delegated');
        require (getIndex(voted, msg.sender) == -1, 'ANDREW: vote already cast');
        require (sender.status != BALLOT_STATUS_NONE, 'ANDREW: no ballot');
        require (proposals[nominateeIndex].proposalType == proposalType, 'ANDREW: type not found'); // requiring 'type' ensures the sender is aware of the proposal type
        require (yayOrNay == 0 || yayOrNay == 1, 'ANDREW: invalid input'); 
        if(yayOrNay == 1) proposals[nominateeIndex].yay += credits[msg.sender];
        else if(yayOrNay == 0) proposals[nominateeIndex].nay += credits[msg.sender];
        voted.push(msg.sender);
        delete voters[msg.sender];
    }

    /// @dev Attempts to assign the trustee
    function execute(uint nominateeIndex) public 
            returns (bool)
    {
        require(proposals[nominateeIndex].authorized, 'ANDREW: denied by Authority');
        uint total = proposals[nominateeIndex].authorizedYay;
        total += proposals[nominateeIndex].authorizedNay;
        if(total >= SafeMath.div (totalSupply(), uint256(majorityDivisor)) && proposals[nominateeIndex].authorizedYay > proposals[nominateeIndex].authorizedNay){
            if(proposals[nominateeIndex].proposalType == VOTE_PROPOSAL_ADD_TRUSTEE){
                require(proposals[nominateeIndex].trusteeNominee != address(0), 'ANDREW: zero address not allowed');
                _addTrustee(proposals[nominateeIndex].trusteeNominee);
            }
            else if(proposals[nominateeIndex].proposalType == VOTE_PROPOSAL_REMOVE_TRUSTEE) {
                _removeTrustee(proposals[nominateeIndex].trusteeNominee);                
            }
            delete proposals;
            delete delegated;
            delete voted;
            majorityDivisor = 2;
            return true;
        }
        return false;
    }

    function getIndex(address[] memory addrs, address ele) internal returns (int) {
        for(uint i = 0; i<addrs.length; i++){
            if(ele == addrs[i]) return int(i);
        }
        return -1;
    }

}
