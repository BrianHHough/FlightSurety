# FlightSurety: an Oracle and Smart Contract-Powered Decentralized Application

## **Definition:** 
FlightSurety is a decentralized application on flight delay insurance for passengers. It's managed as a collaboration between multiple airlines, giving passenters the ability to purcahse insurance prior to a flight. If the flight is delayeddue to the fault of the airline, then the passengers are paid 1.5X the amount they paid for the insurance. Finally, oracles will be used as a mechanism for providing flight status information into the contract.

To note, in a real-world example, the amount that would be paid back to the passengers would most likely be computed with advanced algorithms and methods. The 1.5X figure was an arbitrary one used for examplary purposes and for sake of simplicity.

## Architecture Overview:

This DApp has five components: 
1. **Business applicaton:** the overall delay insurance concept 
2. **Multi-party:** the collaboration between multiple airlines
3. **Payable keyword:** creating transactions where users can pay using the payable keyword
4. **Payout capability:** if the flight is delayed and the passenger has to be paid, it's unwise to send money to passengers, but you'll credit their account and have them withdraw the funds.
5. **Oracles:** used to get the flight information

### A map of the on and off-chain DApp architecture can be be [found](./images/Flight-Surety-Architecture.png) here on in the following image:
![image](./images/Flight-Surety-Architecture.png)

## Project Requirements:

There are five main requirements for the project:
- **Separation of Concerns:**
    - FlightSuretyData contract for data persistence
    - FlightSuretyApp contract for app logic and oracles code
    - DApp client for triggering contract calls (might occur based on user input, for example, a passenger decides to buy insurance for a flight, which would trigger all of the different contract calls)
    - Server app for simulating the behaviors and responses of the oracles
- **Airlines:**
    - Register the first airline when contract is deployed
    - Only existing airline may register a new airline until there are at least four airlines registered
    - Registration of fifth and subsequent airlines requires multi-party consensus of 50% of registered airlines to approve following airlines. 
        - As you create an entity, as more members are welcomed to it, it causes dillution of existing members, they might want to have a say about who's apart of the system.
    - Registration of an airline within smart contract must be two-level:
        1. When they're registered and approved after the multi-party consensus has occured or not approved if the multi-party consensus fails 
        2. All airlines provide some funding within the app (seed funding for the insurance) - requirement for every airline, and each airline must submit 10 Ether
- **Passengers:**
    - Passengers may pay up to 1 Ether for purchasing flight insurance (this is the cap for investing)
    - Flight numbers and timestamps are fixed for the purpose of the project and can be defined in the DApp client (could integrate APIs but those are usually premium services or their free trials are often limited to 7 days)
        - For the purpose of this project, the application has been given arbitrary flight numbers and timestamps and have users select those for insurance.
    - If flight is delayed due to airline fault, passenger receives credit of 1.5X the amount they paid
    - When funds are transfered (when plan delayed), the funds are transfered from contract to the passenger wallet only when they initiate a withdrawl.
        - Reasoning: the debit-before-credit concept
- **Oracles:**
    - Oracles are implemented as a server application (with Node.js)
        - Recommended to use 10, 15 or 20 oracles
        - What could it look like with 100+ oracles?
    - Upon startup, 20+ oracles are registered and their assigned indexes are persisted in memory
        - Having a large number of oracles ensures that we don't have to put a large amount of trust in any single oracle.
    - Client DApp is used to trigger request to update flight status, generating OracleRequest event that is captured by the server
        - Generally, you'd want to create a cluster of oracles that in the simulation resolve the same status code and some that don't. This exercises smart contract code which are checking which oracles provide different information.
        - Oracles know b/c of a button that originates in the UI. Normally, it would originate by a third-party API notifying you or your server app that the flight has landed or has taken off.
    - Because this doesn't use an API, this project's life cycle is as follows for oracle involvement:
        1. A button in the client DApp triggers an event when clicked on.
        2. That event communicates with the smart contract and causes a request to be generated for the oracles.
        3. The oracles then fetch the data for a specific flight.

- **General:**
    - Contracts must have operational status control.
        - Every critical state-changing function within smart contracts must have an ability for them to be paused.
        - Duel-purpose manner (for efficiency): The airlines already have multi-party control, so make it shareable for voting whether a new airline can be registered and voting on whether the application can be paused.
    - Functions must fail fast - use require() at the start of functions.
        - so there is little or no gas expended by the user and costs can be kept low.
    - 
    

## Install

This repository contains Smart Contract code in Solidity (using Truffle), tests (also using Truffle), dApp scaffolding (using HTML, CSS and JS) and server app scaffolding.

To install, download or clone the repo, then:

`npm install`
`truffle compile`

## Develop Client

To run truffle tests:

`truffle test ./test/flightSurety.js`
`truffle test ./test/oracles.js`

To use the dapp:

`truffle migrate`
`npm run dapp`

To view dapp:

`http://localhost:8000`

## Develop Server

`npm run server`
`truffle test ./test/oracles.js`

## Deploy

To build dapp for prod:
`npm run dapp:prod`

Deploy the contents of the ./dapp folder


## Resources

* [How does Ethereum work anyway?](https://medium.com/@preethikasireddy/how-does-ethereum-work-anyway-22d1df506369)
* [BIP39 Mnemonic Generator](https://iancoleman.io/bip39/)
* [Truffle Framework](http://truffleframework.com/)
* [Ganache Local Blockchain](http://truffleframework.com/ganache/)
* [Remix Solidity IDE](https://remix.ethereum.org/)
* [Solidity Language Reference](http://solidity.readthedocs.io/en/v0.4.24/)
* [Ethereum Blockchain Explorer](https://etherscan.io/)
* [Web3Js Reference](https://github.com/ethereum/wiki/wiki/JavaScript-API)