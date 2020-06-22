// changed the ^ to be >= to be less restrictive and allow other versions of solidity >=0.4.25
pragma solidity >=0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

/********************************************************************************************/
/* DATA VARIABLES                                     */
/********************************************************************************************/

    // Account used to deploy contract
    address private contractOwner;
    // Blocks all state changes throughout the contract if false
    bool private operational = true;
    // Add mapping like in FlightSuretyApp.sol
    // mapping(address => bool) private authorizedCallers;
    struct Flight {
        string flightName;
        address airline;
        uint8 statusCode;
        uint256 timestamp;
    }
    struct Airline {
        bool isRegistered;      // Flag for testing existence in mapping
        address account;        // Ethereum account
        uint256 ownership;      // Track percentage of Smart Contract ownership based on initial contribution
    }

    struct Insurance {
        address passenger;
        uint256 insuranceAmount;
    }

    mapping(address => uint8) authorizedCaller;
    mapping(address => Airline) airlines;   // All registered airlines
    mapping(string => Flight) flights;
    mapping(string => address[]) flightInsurees;
    mapping(address => uint256) funds;
    mapping(bytes32 => uint256) flightSurety;

/********************************************************************************************/
/*  EVENT DEFINITIONS                  */
/********************************************************************************************/

    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);
    event CreditInsured(address passenger, string flight, uint256 amount);
    event RegisterAirline   // Event fired when a new Airline is registered
    (
        address indexed account     // "indexed" keyword indicates that the data should be
    // stored as a "topic" in event log data. This makes it
    // searchable by event log filters. A maximum of three
    // parameters may use the indexed keyword per event.
    );
    event RegisterFlight   // Event fired when a new Airline is registered
    (
        string indexed account     // "indexed" keyword indicates that the data should be
    // stored as a "topic" in event log data. This makes it
    // searchable by event log filters. A maximum of three
    // parameters may use the indexed keyword per event.
    );
    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor()
    public {
        contractOwner = msg.sender;
        // contractOwner is a part of the airline owner, whether the airline paid, and starting from 0
        // airlines[contractOwner] = Airline(contractOwner, AirlineState.Paid, "First Airline", 0);
        //
        // totalPaidAirlines++;
    }

    



/********************************************************************************************/
/* FUNCTION MODIFIERS                                 */
/********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in
    *      the event there is an issue that needs to be fixed
    */


    modifier requireIsOperational() {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }



/********************************************************************************************/
/*  UTILITY FUNCTIONS                                  */
/********************************************************************************************/

    /**
    * @dev Retrieve operating status from the contract
    */
    function isOperational()
        public
        view
        returns (bool) {
        // Using return operational = a boolean that indicates the current operating status
        return operational;
    }

    /**
    * @dev This function turns the contract operations on or off
    */
    function setOperatingStatus(
        bool mode)
        external requireContractOwner {
        // If opertional mode is disabled, all write transactions except this one here will fail when run and not work...
        operational = mode;
    }


/********************************************************************************************/
/*  SMART CONTRACT FUNCTIONS LIST                                 */
/********************************************************************************************/

// Need to list out the actual functions of FlightSuretyApp.sol so it knows what to do...this goes here:

    /**
    * @dev This function adds an airline to the registration queue (called only from FlightSuretyApp)
    */
    function registerAirline()
        external
        pure
    {
    }

    /**
    * @dev This function allows for buying insurance for flights
    */
    function buy()
        external
        // we make this function payable so that it can work as a finance/wallet function
        payable
    {
    }

    /**
    * @dev This function credits payment/payout to the people who bought insurance
    */
    function creditInsurees()
        external
        // Note: this isn't a payable function, it's pure
        pure
    {
    }

    /**
    * @dev This function sends payment/payout from the company to the person who bought insurance
    */
    function pay()
        external
        // Note: this isn't a payable function, it's pure
        pure
    {
    }

    /**
    * @dev This function serves as a call for the initial funding for insurance
    */
    function fund()
        public
        // we make this function payable so that it can work as a finance/wallet function
        payable
    {
    }

    /**
    * @dev This function serves as a call for the Flight Key (see: bytes32 of FlightSuretyApp)
    */
    function getFlightKey(
        address airline,
        string memory flight,
        uint256 timestamp
        )
        internal
        pure
        returns(bytes32)
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }


    /**
    * @dev This function serves a fallback in order to fund smart contracts
    */
    function()
        external
        payable
    {
        fund();
    }

}

/********************************************************************************************/
/* INITIAL TRIAL CODE (KEPT FOR REFERENCE FROM FIRST TRY)                                   */
/********************************************************************************************/

/*
    /**
    * @dev Modifier that requires the "authorizedCallers" to determine if that caller is authorized
    */
    /*
    modifier requireCallerAuthorized() {
        require(authorizedCallers[msg.sender] || (msg.sender == contractOwner), "This caller is unfortunately not authorized for this.");
        _;
    }


    function()
    external payable
    {
    }


    function setCallerAuthorizationStatus(address caller, bool status) external requireContractOwner
    returns (bool) {
        authorizedCallers[caller] = status;
        return authorizedCallers[caller];
    }

    function getCallerAuthorizationStatus(address caller) public view requireContractOwner
    returns (bool) {
        return authorizedCallers[caller];
    }

    /*



// Declare AirlineState with three states : applied, registered, paid
enum AirlineState {
    Applied,
    Registered,
    Paid
}

/* Struct is for the airline which has three components:
1. Address
2. State
3. Name */

/*
struct Airline {
    address airlineAddress;
    AirlineState state;
    string name;

    // Add in mapping again, just like in FlightSuretyApp.sol
    mapping(address => bool) approvals;
    uint8 approvalCount;
}

// Add in mapping again, just like in FlightSuretyApp.sol
mapping(address => Airline) internal airlines;
uint256 internal totalPaidAirlines = 0;

/* Create a set of 5 functions that:
1. getAirlineState() = this is to establish the state of each airline
2. createAirline() = this is to create the airline for the potential insurance pool
3. updateAirlineState() = this is to this is to update the DApp about which of the airlines paid/didn't pay
4. getTotalPaidAirlines() = this is to establish which of the airlines paid and are in the pool
5. approveAirlineRegistration() = this is to confirm and allow the paid airline to be in the insurance pool of the DApp
*/

/*
// 1. getAirlineState() = this is to establish the state of each airline
function getAirlineState(address airline) external view
requireCallerAuthorized
returns (AirlineState) {
    return airlines[airline].state;
}

// 2. createAirline() = this is to create the airline for the potential insurance pool
function createAirline(address airlineAddress, uint8 state, string name) external
requireCallerAuthorized {
    airlines[airlineAddress] = Airline(airlineAddress, AirlineState(state), name, 0);
}

// 3. updateAirlineState() = this is to this is to update the DApp about which of the airlines paid/didn't pay
function updateAirlineState(address airlineAddress, uint8 state) external
requireCallerAuthorized {
    airlines[airlineAddress].state = AirlineState(state);
    if (state == 2) totalPaidAirlines++;
}

// NOTE: added to connect with FlightSuretyApp.sol
function updateAirlineState(address airlineAddress, uint8 state) external view
requireCallerAuthorized
returns (uint8) {
    return AirlineState;
}

// 4. getTotalPaidAirlines() = this is to establish which of the airlines paid and are in the pool
function getTotalPaidAirlines() external view
requireCallerAuthorized
returns (uint256) {
    return totalPaidAirlines;
}

// 5. approveAirlineRegistration() = this is to confirm and allow the paid airline to be in the insurance pool of the DApp
function approveAirlineRegistration(address airline, address approver) external requireCallerAuthorized
returns (uint8) {
    require(!airlines[airline].approvals[approver], "Caller has already given approval");
    airlines[airline].approvals[approver] = true;
    airlines[airline].approvalCount++;

    return airlines[airline].approvalCount;
}

*/