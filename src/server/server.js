import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import FlightSuretyData from '../../build/contracts/FlightSuretyData.json';
import Config from './config.json';
import Web3 from 'web3';
import express from 'express';


let config = Config['localhost'];
let web3 = new Web3(new Web3.providers.WebsocketProvider(config.url.replace('http', 'ws')));
web3.eth.defaultAccount = web3.eth.accounts[0];
let flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);
let flightSuretyData = new web3.eth.Contract(FlightSuretyData.abi, config.dataAddress);

// Create a section for calling all of the status codes:
// Corresponds to the smart contracts
let STATUS_CODES = [{
  // Status: unknown status
  "label": "STATUS_CODE_UNKNOWN",
  "code": 0
}, {
  // Status: airline is on time (no payment)
  "label": "STATUS_CODE_ON_TIME",
  "code": 10
}, {
  // Status: airline is late (plane's fault and payment occurs)
  "label": "STATUS_CODE_LATE_AIRLINE",
  "code": 20
}, {
  // Status: weather (no payment)
  "label": "STATUS_CODE_LATE_WEATHER",
  "code": 30
}, {
  // Status: technical issue/not airline's fault (no payment)
  "label": "STATUS_CODE_LATE_TECHNICAL",
  "code": 40
}, {
  // Status: other issue (no payment)
  "label": "STATUS_CODE_LATE_OTHER",
  "code": 50
}];

// Create a function for random indexing
function assignRandomIndex(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Create a function to authorize Caller of new promise
function authorizeCaller(caller) {
  // see lecture videos on promises
  // this promise focuses on two functions: resolve or reject
  return new Promise((resolve, reject) => {
      flightSuretyData.methods.authorizeCaller(config.appAddress).send({
          from: caller
      // use .then and .catch features to clarify post-return
      }).then(result => {
          console.log(result ? `Caller: ${caller} is authorized` : `Caller: ${caller} is not authorized`);
          return (result ? resolve : reject)(result);
      // use .catch for finding errors.
      // If error, then reject the error and return that...
      }).catch(err => {
          reject(err);
      });
  })

}

// establish function for initializing accounts
function initAccounts() {
  return new Promise((resolve, reject) => {
    web3.eth.getAccounts().then(accounts => {
      web3.eth.defaultAccount = accounts[0];
      authorizeCaller(
        accounts[0]
      ).then(result => {
        FlightSuretyApp.methods.fund(accounts[0]).send({
          from: accounts[0],
          "value": 10,
          "gas": 4712388,
          "gasPrice": 100000000000
        }).then(() => {
          initREST();
          console.log("funds added");
        }).catch(err => {
          console.log("Error funding the first account");
          console.log(err.message);
        }).then(() => {
          resolve(accounts);
        });
      }).catch(err => {
        console.log(err.message);
        reject(err);
      });
    }).catch(err => {
      reject(err);
    });
  });
}

function initOracles(accounts) {
  return new Promise((resolve, reject) => {
    let rounds = accounts.length;
    let oracles = [];
    FlightSuretyApp.methods.REGISTRATION_FEE().call().then(fee => {
      accounts.forEach(account => {
        FlightSuretyApp.methods.registerOracle().send({
          "from": account,
          "value": fee,
          "gas": 4712388,
          "gasPrice": 100000000000
        }).then(() => {
          FlightSuretyApp.methods.getMyIndexes().call({
            "from": account
          }).then(result => {
            oracles.push(result);
            console.log(`Oracle Registered: 
              ${result[0]}, 
              ${result[1]}, 
              ${result[2]} at ${account}`);
            rounds -= 1;
            if (!rounds) {
              resolve(oracles);
            }
          }).catch(err => {
            reject(err);
          });
        }).catch(err => {
          reject(err);
        });
      });
      }).catch(err => {
        reject(err);
      });
    });
  }
  // establish methods for initializing accounts
  initAccounts().then(accounts => {
    initOracles(accounts).then(oracles => {
      FlightSuretyApp.events.OracleRequest({
          fromBlock: "latest"
      }, function (error, event) {
        if (error) {
          console.log(error)
        }
        let airline = event.returnValues.airline;
        let flight = event.returnValues.flight;
        let timestamp = event.returnValues.timestamp;
        let found = false;
  
        let selectedCode = STATUS_CODES[1];
        let scheduledTime = (timestamp * 1000);
        console.log(`Flight scheduled to: ${new Date(scheduledTime)}`);
        if (scheduledTime < Date.now()) {
          //disable for debugging
          // selectedCode = STATUS_CODES[assignRandomIndex(2, STATUS_CODES.length - 1)];
          selectedCode = STATUS_CODES[2];
          }
      // establish forEach methods for the oracles    
      oracles.forEach((oracle, index) => {
        // establish found and foreach methods
        if (found) {
          return false;
        }
        for(let idx = 0; idx <3; idx += 1) {
          if (found) {
            break;
          }
          if (selectedCode.code === 20) {
            console.log("WILL COVER USERS");
            FlightSuretyApp.methods.creditInsurees(
              accounts[index],
              flight
            ).send({
              from: accounts[index]
            }).then(result => {
              console.log(result);
              console.log(`Flight ${flight} got covered and insured the users`);
            }).catch(err => {
                console.log(err.message);
            });
          }
          FlightSuretyApp.methods.submitOracleResponse(
            oracle[idx], airline, flight, timestamp, selectedCode.code
            // .send method
            ).send({
                from: accounts[index]
            // .then method
            }).then(result => {
              found = true;
              console.log(`Oracle: ${oracle[idx]} responded from flight ${flight} with status ${selectedCode.code} - ${selectedCode.label}`);
            }).catch(err => {
                console.log(err.message);
            }); // close out .catch
              }
            }); // close out .then
          }); // close out .send
          // create method for catching errors
          // if receive error, then return error message
        }).catch(err => {
          console.log(err.message);
      });
  // create method for catching errors
  // if receive error, then return error message
  }).catch(err => {
    console.log(err.message);
  });
  
/*
// Create a function to authorize Caller of new promise
function authorizeCaller(caller) {
  // see lecture videos on promises
  // this promise focuses on two functions: resolve or reject
  return new Promise((resolve, reject) => {
      flightSuretyData.methods.authorizeCaller(config.appAddress).send({
          from: caller
      // use .then and .catch features to clarify post-return
      }).then(result => {
          console.log(result ? `Caller: ${caller} is authorized` : `Caller: ${caller} is not authorized`);
          return (result ? resolve : reject)(result);
      // use .catch for finding errors.
      // If error, then reject the error and return that...
      }).catch(err => {
          reject(err);
      });
  })

}
*/




// app = express
const app = express();
// function for initializing REST / API
function initREST() {
  app.get('/api', (req, res) => {
    res.send({
      message: 'An API for use with your Dapp!'
    });
  });
  // for all the active Airlines available
  app.get("/activeAirlines", (req, res)  => {
    FlightSuretyApp.methods.getActiveAirlines().call().then(airlines => {
        console.log(airlines);
        return res.status(200).send(airlines);
        // if there's an error, catch it and send back err message
    }).catch(err => {
        return res.status(500).send(err);
    });
  });
}

export default app;
