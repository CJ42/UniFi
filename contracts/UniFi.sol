pragma solidity ^0.6.0;

/// @title Unifi contract - EthLondon Hackathon
/// @author Extropy.io team
/// @notice You can use this contract to get paid for sharing your wifi
/// @dev Are we going to implement ERC20 Token?
contract UniFi {
    
    // Minimum topup is 10 MB = 10,000,000,000,000 wei
    uint constant minimum_topup = 10_000_000_000_000 wei;
    uint8 base_rating = 3;
    
    struct User {
        bool is_connected;  // to the wifi?
        bool is_registered; // have he ever used Uni-Fi
        uint256 balance;
    }
    
    struct Host {
        uint256 balance;
        uint256 longitude;
        uint256 latitude;
        uint256 users_connected;
        uint256 base_fee;
        string ssid;
        string mac_address;
        uint8[5] rating;
    }
    
    mapping(address => Host) host_array;
    mapping(address => User) public user_array;
    mapping(address => uint) pendingWithdrawals;
    
    constructor() public {
       // set owner
    }
    
    modifier isConnected(address user) {
        require(user_array[user].is_connected == true);
        _;
    }
    
    modifier isNotConnected(address user) {
        require(user_array[user].is_connected == false);
        _;
    }

    /// Get user balance
    /// @return the user balance
    function getUserBalance() public view returns(uint) {
        return user_array[msg.sender].balance;
    }
    
    /// @notice registering host (SSID: `_ssid`, MAC: `_mac_address`)
    /// @dev 
    /// @param _longitude wifi longitude (geolocation)
    /// @param _latitude wifi latitude (geolocation)
    /// @param _ssid SSID of the wifi host
    /// @param _mac_address Mac Address
    function registerHost(
        uint256 _longitude,
        uint256 _latitude,
        uint256 _base_fee,
        string memory _ssid,
        string memory _mac_address 
    ) public {
        host_array[msg.sender].base_fee = _base_fee;
        host_array[msg.sender].longitude = _longitude;
        host_array[msg.sender].latitude = _latitude;
        host_array[msg.sender].ssid = _ssid;
        host_array[msg.sender].mac_address = _mac_address;
        host_array[msg.sender].balance = 0;
    }
    
    /// @notice Congrats have been registered !
    /// @dev Set the balance to 0 by default
    function registerUser() private isNotConnected(msg.sender){
        user_array[msg.sender] = User({
            is_connected: false,
            is_registered: true,
            balance: 0
        });
    }
    
    /// @notice Congrats `_host`, you have been granted some reputation! New reputation = `_rep` + 1
    /// @dev Set rep
    /// @param _host The host to reward reputation
    /// @param _rep the number of reputation to grant
    function repHost(address _host, uint8 _rep) internal {
        host_array[_host].rating[_rep] += 1;
    }
    
    /// @notice Log-in successfully to the host
    /// @dev Shouldn't we define to which host the user is logged in?
    function login() public isNotConnected(msg.sender) {
        if ( user_array[msg.sender].is_registered == false ) {
            registerUser();
        }
        // here we login
        user_array[msg.sender].is_connected = true;
    }
    
    /// @notice You have been logged out
    /// @dev Same, shouldn't we specify the host that we log-out from?
    /// @param user the user to log-out
    /// @param charge the charge to apply
    function logout(address user, uint charge) public isConnected(user) {
        // subtract the charge
        user_array[user].balance -= charge;
        withdrawUser();
        //address(this).transfer(due_to_contract);
        // user.transfer(due_to_user);
        user_array[user].is_connected = false;
    }
    

    /// @notice you are about to top up your balance
    /// @dev we shouldn't use the keyword `balance` for struct member 
    ///      since it's a reserved keyword in Solidity (for clarity)
    function deposit() public payable {
        user_array[msg.sender].balance += msg.value;
    }
    
    /// @notice 
    /// @dev Use the pending withdraw pattern
    function withdrawHost() public {
        // subtract user usage from host balance
        uint amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
    
    /// @notice
    /// @dev
    function withdrawUser() public {
        // subtract user usage from user balance
        uint amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        msg.sender.transfer(amount);
        pendingWithdrawals[msg.sender] = 0;
    }
    
    /// Handle ethers received by the contract
    receive() external payable {}
    
    /// Handle undefined function calls
    fallback() external {
        revert();
    }
}
