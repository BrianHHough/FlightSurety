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

![image](./images/Flight-Surety-Architecture.png)


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