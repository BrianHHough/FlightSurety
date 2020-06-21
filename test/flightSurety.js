// Updated "var" to "const"
// UPDATE TO UPDATE: changed back to "var"
const Test = require('../config/testConfig.js');
// add in truffle assertion about requiring truffle here:
// const truffleAssert = require('truffle-assertions');
// const truffleAssert = require('truffle-assertions');
const BigNumber = require('bignumber.js');

// establish a series of let components leading up to testing the contracts to establish the variables and items to analyze:

// let's for accounts/to initialize
// let config; // changed from var config
// let accounts;
// let's for airlines
// let firstAirline; // 1st airline
// let secondAirline; // 2nd airline
// let thirdAirline; // 3rd airline
// let fourthAirline; // 4th airline
// let fifthAirline; // 5th airline
// one final let for the passenger
// let passenger;

contract('Flight Surety Tests', async (accounts) => {
    // accounts = acc;
        // firstAirline = accounts[0]; 
        // secondAirline = accounts[1]; 
        // thirdAirline = accounts[2]; 
        // fourthAirline = accounts[3]; 
        // fifthAirline = accounts[4];
        // passenger = accounts[5];
    var config;
    // removed before('setup contract', async...)
    before('setup contract', async () => {
        config = await Test.Config(accounts);
        // await config.flightSuretyData.authorizeCaller(config.flightSuretyApp.address);
    });

  /****************************************************************************************/
  /*                                 Operations and Settings                              */
  /****************************************************************************************/

it(`(multiparty) has correct initial isOperational() value`, async function () {

    // Get operating status
    let status = await config.flightSuretyData.isOperational.call();
    // "This is an incorrect initial operating status value for smart contract: flightSuretyData.sol!");
    assert.equal(status, true, "This is an incorrect initial operating status value for smart contract: flightSuretyApp.sol!");
  });

/*
  it('flightSurretyApp is authorized to make calls to flightSuretyData', async function () {
      const status = await config.flightSuretyData.getCallerAuthorizations(config.flightSuretyApp.address);
      assert.equal(status, true, "flightSuretyApp isn't authorized to function like this.");
  });
*/

  it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: config.testAddresses[2] });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
            
  });

  it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {

      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false);
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
      
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {

      await config.flightSuretyData.setOperatingStatus(false);

      let reverted = false;
      try 
      {
          await config.flightSurety.setTestingMode(true);
      }
      catch(e) {
          reverted = true;
      }
      assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await config.flightSuretyData.setOperatingStatus(true);

  });

  it('(airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    try {
        await config.flightSuretyApp.registerAirline(newAirline, {from: config.firstAirline});
    }
    catch(e) {

    }
    /*let result = await config.flightSuretyData.isAirline.call(newAirline); 
    // ASSERT
    assert.equal(result, false, "Airline should not be able to register another airline if it hasn't provided funding");
*/
  });
 

});