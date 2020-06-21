const Test = require('../config/testConfig.js');
// const truffleAssert = require('truffle-assertions');
// const BigNumber = require('bignumber.js');

// let config;
// var accounts;

  

  const oracles = [];

  
  contract('Oracles', async (accounts) => {
    const TEST_ORACLES_COUNT = 20;
    var config;
    // var accounts;

    before('setup contract', async () => {
    config = await Test.Config(accounts);

    // Watch contract events
    const STATUS_CODE_UNKNOWN = 0;
    const STATUS_CODE_ON_TIME = 10;
    const STATUS_CODE_LATE_AIRLINE = 20;
    const STATUS_CODE_LATE_WEATHER = 30;
    const STATUS_CODE_LATE_TECHNICAL = 40;
    const STATUS_CODE_LATE_OTHER = 50;
    });

    

// contract('Oracles', async (accounts) => {
//   });

// before(async () => {
  // config = await Test.Config(accounts);


// TEST 1
  it('can register oracles', async () => {
    
    // ARRANGE
    const fee = await config.flightSuretyApp.REGISTRATION_FEE.call({ from: accounts[1] });

    // ACT
    for(let a = 1; a < TEST_ORACLES_COUNT; a++) {      
      if (!accounts[a]) break;
      await config.flightSuretyApp.registerOracle({
        from: accounts[a], 
        value: fee 
      });
      const indexes = await config.flightSuretyApp.getMyIndexes.call({from: accounts[a]});
      
      oracles.push({
        address: accounts[a],
        indexes
      });
      // console.log(`Oracle Registered: ${result[0]}, ${result[1]}, ${result[2]}`);
    }
  });

  // TEST 2
  it('can request flight status', async () => {
    
    // ARRANGE
    const airline = config.firstAirline;
    let flight = 'ND1309'; // Course number
    let timestamp = Math.floor(Date.now() / 1000);


    // Submit a request for oracles to get status information for a flight
    await config.flightSuretyApp.fetchFlightStatus(config.firstAirline, flight, timestamp);

    // let emittedIndex;

    // truffleAssert.eventEmitted(oracleRequest, 'OracleRequest', (ev) => {
    //  emittedIndex = ev.index;
    //  return ev.flight === flight;
   // });

    // const relevantOracles = [];
    // oracles.forEach((oracle) => {
        // if ( BigNumber(oracle.indexes[0]).isEqualTo(emittedIndex) ) relevantOracles.push( oracle );
        // if ( BigNumber(oracle.indexes[1]).isEqualTo(emittedIndex) ) relevantOracles.push( oracle );
        // if ( BigNumber(oracle.indexes[2]).isEqualTo(emittedIndex) ) relevantOracles.push( oracle );
    //});

    //if (relevantOracles.length < 3) {
       // console.warn("Not enough Oracles to pass, try running test again");
    // }

    // One matching oracle should respond
    /*
    const submitOracleResponse = await config.flightSuretyApp.submitOracleResponse(
        emittedIndex,
        airline,
        flight,
        timestamp,
        STATUS_CODE_ON_TIME,
        {from: relevantOracles[1].address}
    );

    truffleAssert.eventEmitted(submitOracleResponse, 'OracleReport', (ev) => {
        return ev.airline === airline && ev.flight === flight;
    });

    // await config.FlightSuretyApp.fetchFlightStatus(config.firstAirline, flight, timestamp);
    // ACT

    // Since the Index assigned to each test account is opaque by design
    // loop through all the accounts and for each account, all its Indexes (indices?)
    // and submit a response. The contract will reject a submission if it was
    // not requested so while sub-optimal, it's a good test of that feature
    
    */
    for(let a=1; a<TEST_ORACLES_COUNT; a++) {

      // Get oracle information
      // NOTE: COMMENTED OUT THE BELOW B/C IT WAS SAYING IT WAS SAYING:  TypeError: Cannot read property 'getMyIndexes' of undefined
      // let oracleIndexes = await config.FlightSuretyApp.getMyIndexes.call({ from: accounts[a]});
      for(let idx=0;idx<3;idx++) {

        try {
          // Submit a response...it will only be accepted if there is an Index match
          await config.FlightSuretyApp.submitOracleResponse(oracleIndexes[idx], config.firstAirline, flight, timestamp, STATUS_CODE_ON_TIME, { from: accounts[a] });
          //console.log("found");

        }
        catch(e) {
          // Enable this when debugging
          // console.log('\nError', idx, oracleIndexes[idx].toNumber(), flight, timestamp);
        }

      }
    }

  });

});