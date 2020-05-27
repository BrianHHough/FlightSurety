// changed the ^ to be >= to be less restrictive and allow other versions of solidity
pragma solidity >=0.4.25;

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

// Import SafeMath solidity library from Open-Zeppelin:
import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

/************************************************** */
/* FlightSurety Smart Contract                      */
/************************************************** */
contract FlightSuretyApp {
    // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                GLOBAL DATA VARIABLES                                     */
    /********************************************************************************************/

    // Account used to deploy contract
    address private contractOwner;
    // establish boolean for contract either being operational or not operational:
    bool private operational = true;

    // data is persisted
    FlightSuretyData flightSuretyData;

    address flightSuretyDataContractAddress;

    /********************************************************************************************/
    /*              CONSTRUCTORS; FUNCTION MODIFIERS; UTILITY FUNCTIONS                         */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational()
    {
         // Modify to call data contract's status
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier onlyRegisteredAirlines()
    {
        require(flightSuretyData.getAirlineState(msg.sender) == 1, "Only registered allowed");
        _;
    }

    modifier onlyPaidAirlines()
    {
        require(flightSuretyData.getAirlineState(msg.sender) == 2, "Only the airlines that have paid are allowed to be part of the pool!");
        _;
    }


   /********************************************************************************************/
    /*                                       CONSTRUCTORS                                       */
    /********************************************************************************************/

    /**
    * @dev Contract constructor
    *
    */
    constructor(address dataContractAddress)
    public
    {
        contractOwner = msg.sender;

        flightSuretyDataContractAddress = dataContractAddress;
        // establish variable
        flightSuretyData = FlightSuretyData(flightSuretyDataContractAddress);


        // First flights -- start

        bytes32 flightKey1 = getFlightKey(
            contractOwner,
            "FLIGHT1",
            now
        );
            flights[flightKey1] = Flight(
                STATUS_CODE_UNKNOWN,
                now,
                contractOwner,
                "FLIGHT1"
        );
            flightsKeyList.push(flightKey1);
        
        bytes32 flightKey2 = getFlightKey(
            contractOwner,
            "flight2",
            now + 1 days
        );
            flights[flightKey2] = Flight(
                STATUS_CODE_UNKNOWN,
                now + 1 days,
                contractOwner,
                "FLIGHT2"
            );
            flightsKeyList.push(flightKey2);
        
        bytes32 flightKey3 = getFlightKey(
            contractOwner,
            "FLIGHT3",
            now + 2 days
        );
            flights[flightKey3] = Flight(
                STATUS_CODE_UNKNOWN,
                now + 2 days,
                contractOwner,
                "FLIGHT3"
            );
            flightsKeyList.push(flightKey3);
    }

    function isOperational() public view returns (bool)
    {
        return operational;
    }

    // IMPLEMENT OPTIONAL STATUS UPDATE
    function setOperatingStatus (bool mode) external requireContractOwner
    {
        operational = mode;
    }

 /********************************************************************************************/
 /*                                     AIRLINE FUNCTIONS                                    */
 /********************************************************************************************/

    // establish constant variable about counting consensus needed (need more than half for majority stake/consensus building)
    uint8 private constant NO_AIRLINES_REQUIRED_FOR_CONSENSUS_VOTING = 4;

    /* Establish 3 events for Airline that can happen:
    1. Applied
    2. Registered
    3. Paid */
    event AirlineApplied(address airline);
    event AirlineRegistered(address airline);
    event AirlinePaid(address airline);

    /* Establish 3 functions for Airlines:
    1. applyForAirlineRegistration() = the airline applies for registration - this is an external "action"
    2. approveAirlineRegistration() = approve the airline's registrations - this is a boolean: it either is approved or rejected
    3. payAirlineDues() = this is a payable function where only the registered airlines makes a payment */

    // 1. applyForAirlineRegistration() = the airline applies for registration - this is an external "action"
    // NOTE: added calldata, before it was just (string airlineName)
    function applyForAirlineRegistration(string airlineName) external
    {
        flightSuretyData.createAirline(msg.sender, 0, airlineName);
        emit AirlineApplied(msg.sender);
    }

    // 2. approveAirlineRegistration() = approve the airline's registrations - this is a boolean: it either is approved or rejected
    function approveAirlineRegistration(address airline) external onlyPaidAirlines {
        require(flightSuretyData.getAirlineState(airline) == 0, "Unfortunately, this airline hasn't applied for approval just yet.");

        // Make this a boolean function where something is either true or false:
        bool approved = false;
        uint256 totalPaidAirlines = flightSuretyData.getTotalPaidAirlines();

        // Make the total paid by the airlines less than the amount required for voting consensus (so it's not more than potential total amount)
        if (totalPaidAirlines < NO_AIRLINES_REQUIRED_FOR_CONSENSUS_VOTING) {
            approved = true;
        } else {
            // approval count must be ONLY the approved airline registrations
            uint8 approvalCount = flightSuretyData.approveAirlineRegistration(airline, msg.sender);
            uint256 approvalsRequired = totalPaidAirlines / 2;
            if (approvalCount >= approvalsRequired) approved = true;
        }

        // If airline paid, then acknowledge the airline as registered
        if (approved) {
            flightSuretyData.updateAirlineState(airline, 1);
            emit AirlineRegistered(airline);
        }
    }
    
    // 3. payAirlineDues() = this is a payable function where only the registered airlines makes a payment with onlyRegisteredAirlines
    function payAirlineDues() external payable { address onlyRegisteredAirlines;
        require(msg.value == 10 ether, "The required payment of 10 ethere is due.");
        flightSuretyDataContractAddress.transfer(msg.value);
        FlightSuretyData.updateAirlinesState(msg.sender, 2);
        emit AirlinePaid(msg.sender);
    }


 /********************************************************************************************/
 /*                          PASSENGER INSURANCE CODES / FUNCTIONS                           */
 /********************************************************************************************/
uint8 private constant MAX_INSURANCE_AMOUNT;
uint8 private constant INSURANCE_DIVIDER;
// uint8 private nonce = 0;
// uint256 public constant INSURANCE_DIVIDER = 2;

// event passengerInsuranceBought(address passenger, bytes32 flightKey);

/* CREATE A SET OF FIVE FUNCTIONS:
1. purchaseInsurance() = allows passengers to buy insurance ahead of the flight as payable function
2. getInsurance() = allows passenger to receive insurance after buying it
3. claimInsurance() = allows passenger to claim the right to the insurance they got
4. getBalance() = allows passenger to receive payout from the airline if flight is delayed
5. withdrawBalance() = allows passenger to withdraw the payout into their digital wallet

*/

// 1. purchaseInsurance() = allows passengers to buy insurance ahead of the flight as payable function
// NOTE: this is a external payable function
function purchaseInsurance(address airline, string flight, uint256 timestamp) external payable
{
    bytes32 flightKey = getFlightKey(airline, flight, timestamp);

    require(bytes(flights[flightKey].flight).length > 0, "This flight is not an existing one");

    require(msg.value <= MAX_INSURANCE_AMOUNT, "Did you know that passengers can only buy a maximum of 1 ETH for insurance?");

    flightSuretyDataContractAddress.transfer(msg.value);

    uint256 payoutAmount = msg.value + ( msg.value / INSURANCE_DIVIDER);

    FlightSuretyData.createInsurance(msg.sender,flight, msg.value, payoutAmount);

    emit passengerInsuranceBought(msg.sender,flightKey);
}

// 2. getInsurance() = allows passenger to receive insurance after buying it
// NOTE: this is an external view function
function getInsurance(string flight) external view
returns (uint256 amount, uint256 payoutAmount, uint256 state)
{
    return FlightSuretyData.getInsurance(msg.sender, flight);
}

// 3. claimInsurance() = allows passenger to claim the right to the insurance they got
function claimInsurance(address airline, string flight, uint256 timestamp) external
{
    bytes32 flightKey = getFlightKey(airline, flight, timestamp);
    require(flights[flightKey].statusCode == STATUS_CODE_LATE_AIRLINE, "This flight was not delayed and insurance will not be paid out");

    FlightSuretyData.claimInsurance(msg.sender, flight);
}

// 4. getBalance() = allows passenger to receive payout from the airline if flight is delayed
// NOTE: this is an external view function
function getBalance() external view
returns (uint256 balance)
{
    balance = FlightSuretyData.getPassengerBalance(msg.sender);
}

// 5. withdrawBalance() = allows passenger to withdraw the payout into their digital wallet
function withdrawBalance() external
{
    FlightSuretyData.payPassenger(msg.sender);
}


 /********************************************************************************************/
 /*                               FLIGHT STATUS CODES / FUNCTIONS                            */
 /********************************************************************************************/


    // Flight status codes
    // Late_Airline (20) is related to only the airline - this would trigger the payment to the passengers who invested...everything else a product of nature/not related to airline's fault.
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    // ONLY when the airline is late is there a payout
    // The 20 score is the only flight code where passengers are paid out
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20; // <--------------------- IMPORTANT ONE HERE
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;


    // Define struct of "Flight"
    struct Flight {
        uint8 statusCode;
        uint256 updatedTimestamp;
        address airline;
    }

    // Define mapping of "Flight"
    mapping(bytes32 => Flight) private flights;
    bytes32[] private flightsKeyList;


    event FlightStatusProcessed(address airline, string flight, uint8 statusCode);

 /**
    * @dev Add an airline to the registration queue
    *
    */   
    function registerAirline() external pure
    returns(
        bool success, 
        uint256 votes){
        return (success, 0);
    }

    function getFlightsCount() external view returns(uint256 count) {
        return flightsKeyList.length;
    }

    function getFlight(uint256 index) external view returns(
        address airline,
        string memory flight,
        uint256 timestamp,
        uint8 statuscode){
            airline = flights[ flightsKeyList[index] ].airline;
            flight = flights[ flightsKeyList[index] ].flight;
            timestamp = flights[ flightsKeyList[index] ].timestamp;
            statuscode = flights[ flightsKeyList[index] ].statuscode;
        }

     /**
    * @dev Register a future flight for insuring.
    *
    */

    function registerFlight(
        uint8 status,
        string flight)
    external onlyPaidAirlines{
        bytes32 flightKey = getFlightKey(msg.sender, flight, now);

        flights[flightKey] = Flight(status, now, msg.sender, flight);
        flightsKeyList.push(flightKey);
    }

    /**
    * @dev Called after oracle has updated flight status
    *
    */

    function processFlightStatus(
        address airline,
        string memory flight,
        uint256 timestamp,
        uint8 statusCode)
    private{
        bytes32 flightKey = getFlightKey(airline, flight, timestamp);
        flights[flightKey].statusCode = statusCode;

        emit FlightStatusProcessed(airline, flight, statusCode);
    }

    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus(
        address airline, 
        string flight, 
        uint256 timestamp)
    external{
        uint8 index = getRandomIndex(msg.sender);
        // Generate a unique key for storing the request
        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp));
        oracleResponses[key] = ResponseInfo({
            requester : msg.sender,
            isOpen : true
        });
        emit OracleRequest(index, airline, flight, timestamp);
    }

/********************************************************************************************/
/*                                       ORACLE MANAGEMENT                                  */
/********************************************************************************************/

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;


    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;
    }

    // Track all registered oracles
    mapping(address => Oracle) private oracles;

    // Model for responses from oracles
    struct ResponseInfo {
        address requester;                              // Account that requested status
        bool isOpen;                                    // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses;          // Mapping key is the status code reported
                                                        // This lets us group responses and identify
                                                        // the response that majority of the oracles
    }

    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;

    // Event fired each time an oracle submits a response
    event FlightStatusInfo(address airline, string flight, uint256 timestamp, uint8 status);

    event OracleReport(address airline, string flight, uint256 timestamp, uint8 status);

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    event OracleRequest(uint8 index, address airline, string flight, uint256 timestamp);


    // Register an oracle with the contract
    function registerOracle() external payable
    {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);

        oracles[msg.sender] = Oracle({
            isRegistered: true,
            indexes: indexes
        });
    }

    // NOTE: added memory after uint8[3] b/c "Error: Data location must be "memory" for return parameter in function, but none was given."
    function getMyIndexes() external view
    returns(uint8[3] memory)
    {
        require(oracles[msg.sender].isRegistered, "Not registered as an oracle");

        return oracles[msg.sender].indexes;
    }


    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse(
        uint8 index,
        address airline,
        string flight,
        uint256 timestamp,
        uint8 statusCode
    )
    external
    {
        require(
            (oracles[msg.sender].indexes[0] == index) ||
            (oracles[msg.sender].indexes[1] == index) ||
            (oracles[msg.sender].indexes[2] == index), "Index does not match oracle request"
        );


        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp));
        require(oracleResponses[key].isOpen, "Flight or timestamp do not match oracle request");

        oracleResponses[key].responses[statusCode].push(msg.sender);

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airline, flight, timestamp, statusCode);
            
            if (oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES) {

            emit FlightStatusInfo(airline, flight, timestamp, statusCode);

            // Handle flight status as appropriate
            processFlightStatus(airline, flight, timestamp, statusCode);
        }
    }


    function getFlightKey(
        address airline,
        string memory flight,
        uint256 timestamp
    )
    pure
    internal
    returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    // Returns array of three non-duplicating integers from 0-9
    // NOTE: added memory after uint8[3] b/c "Error: Data location must be "storage" or "memory" for return parameter in function, but none was given."
    function generateIndexes(address account)
    internal returns(uint8[3] memory)
    {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(account);

        indexes[1] = indexes[0];
        while(indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex(address account)
    internal returns (uint8)
    {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), account))) % maxValue);

        if (nonce > 250) {
            nonce = 0;  // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }

}

/********************************************************************************************/
/*                                 END REGION - DATA CONTRACT                               */
/********************************************************************************************/

// Note: added in "external" to the external view components below to avoid error: "security/enforce-explicit-visibility: No visibility specified explicitly for getAirlineState function."

contract FlightSuretyData {
    function getAirlineState(address airline) public
    returns(uint)
    {
        return 1;
    }

    function createAirline(address airlineAddress, uint8 state, string memory name) public
    {}

    function updateAirlineState(address airlineAddress, uint8 state) public
    {}

    function getTotalPaidAirlines() public
    returns (uint)
    {
        return 1;
    }

    function approveAirlineRegistration(address airline, address approver) public
    returns (uint8)
    {
        return 1;
    }

    function createInsurance(address passenger, string memory flight, uint256 amount, uint256 payoutAmount) public
    {}

    function getInsurance(address passenger, string memory flight) public
    returns (uint256 amount, uint256 payoutAmount, uint256 state)
    {
        amount = 1;
        payoutAmount = 1;
        state = 1;
    }

    function claimInsurance(address passenger, string memory flight) public
    {}

    function getPassengerBalance(address passenger) public
    returns (uint256)
    {
        return 1;
    }

    function payPassenger(address passenger) public
    {}

}

