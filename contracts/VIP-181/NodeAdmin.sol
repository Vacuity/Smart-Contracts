import "/Users/shermanmonroe/Documents/GitHub/andrew/openzeppelin-solidity/contracts/access/Roles.sol";
pragma solidity ^0.5.0;

contract NodeAdmin {

    using Roles for Roles.Role;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    Roles.Role private _admins;

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Escrow: caller does not have the trustee role");
        _;
    }

    constructor () internal {
        _addAdmin(msg.sender);
    }

    function isAdmin(address account) public view returns (bool) {
        return _admins.has(account);
    }

    function renounceAdmin() public {
        _removeAdmin(msg.sender);
    }

    function _addAdmin(address account) internal {
        require(account != address(0), 'NodeAdmin: zero address not allowed');
        _admins.add(account);
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        _admins.remove(account);
        emit AdminRemoved(account);
    }
}
