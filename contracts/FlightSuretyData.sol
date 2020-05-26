// changed the ^ to be >= to be less restrictive and allow other versions of solidity >=0.4.25
pragma solidity >=0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    // Account used to deploy contract
    address private contractOwner;
    // Blocks all state changes throughout the contract if false
    bool private operational = true;
    // Add mapping like in FlightSuretyApp.sol
    mapping(address => bool) private authorizedCallers;


/********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
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

    /**
    * @dev Modifier that requires the "authorizedCallers" to determine if that caller is authorized
    */
    modifier requireCallerAuthorized() {
        require(authorizedCallers[msg.sender] || (msg.sender == contractOwner), "This caller is unfortunately not authorized for this.");
        _;
    }

    /********************************************************************************************/
    /*                  CONSTRUCTORS; FUNCTION MODIFIERS; UTILITY FUNCTIONS                     */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor() 
    public {
        contractOwner = msg.sender;
        // contractOwner is a part of the airline owner, whether the airline paid, and starting from 0
        airlines[contractOwner] = Airline(contractOwner, AirlineState.Paid, "First Airline", 0);
        // 
        totalPaidAirlines++;
    }

    function()
    external payable 
    {
    }

    function isOperational() public view
    returns (bool) {
        return operational;
    }

    function setOperatingStatus(bool mode) external requireContractOwner {
        operational = mode;
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

    

/********************************************************************************************/
/*                                  AIRLINE UTILITY FUNCTIONS                                  */
/********************************************************************************************/

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

// 1. getAirlineState() = this is to establish the state of each airline
function getAirlineState(address airline) external view
requireCallerAuthorized
returns (AirlineState) {
    return airlines[airline].state;
}

// 2. createAirline() = this is to create the airline for the potential insurance pool
function createAirline(address airlineAddress, uint8 state, string calldata name) external
requireCallerAuthorized {
    airlines[airlineAddress] = Airline(airlineAddress, AirlineState(state), name, 0);
}

// 3. updateAirlineState() = this is to this is to update the DApp about which of the airlines paid/didn't pay
function updateAirlineState(address airlineAddress, uint8 state) external
requireCallerAuthorized {
    airlines[airlineAddress].state = AirlineState(state);
    if (state == 2) totalPaidAirlines++;
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


/********************************************************************************************/
/*                               PASSENGER UTILITY FUNCTIONS                                */
/********************************************************************************************/

/* Struct is for the passenger which has two components:
1. Bough
2. Claimed */
enum InsuranceState {
    Bought,
    Claimed
}

struct Insurance {
    string flight;
    uint256 amount;
    uint256 payoutAmount;
    InsuranceState state;
}

mapping(address => mapping(string => Insurance)) private passengerInsurances;
mapping(address => uint256) private passengerBalances;

function getInsurance(address passenger, string calldata flight)
    external
    view
    requireCallerAuthorized
    returns (
        uint256 amount,
        uint256 payoutAmount,
        InsuranceState state) {
            amount = passengerInsurances[passenger][flight].amount;
            payoutAmount = passengerInsurances[passenger][flight].payoutAmount;
            state = passengerInsurances[passenger][flight].state;
        }

function createInsurance(address passenger, string calldata flight, uint256 amount, uint256 payoutAmount)
external
requireCallerAuthorized {
    require(passengerInsurances[passenger][flight].amount != amount, "This amount of insurance is already in existence");
    passengerInsurances[passenger][flight] = Insurance(flight, amount, payoutAmount, InsuranceState.Bought);
}

function claimInsurance(address passenger, string calldata flight)
external
requireCallerAuthorized {
    require(passengerInsurances[passenger][flight].state == InsuranceState.Bought, "This amount of insurance has already been claimed!");
    passengerInsurances[passenger][flight].state = InsuranceState.Claimed;
    
    passengerBalances[passenger] = passengerBalances[passenger] + passengerInsurances[passenger][flight].payoutAmount;
}

function getPassengerBalance(address passenger)
external
view
requireCallerAuthorized
returns (uint256) {
    return passengerBalances[passenger];
}

function payPassenger(address passenger)
external
requireCallerAuthorized {
    require(passengerBalances[passenger] > 0, "This passenger unfortunately does not have enough funds to withdraw that amount to their digital wallet.");
    passengerBalances[passenger] = 0;
    passenger.transfer(passengerBalances[passenger]);
}

}

