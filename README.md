# Bucket Oracle
Mock oracle on Sui testnet, feeding prices from Binance.

## Testnet
Package ID
```
0xdea30c04331a4fe5a04cbd4acafdf9d774d022c6787aa3b160d667419e1e85af
```
Oracle Object ID
```
0x5d552a9bd3162633c6990b8f8cbdc3a4280eec3687cdcb05984a977f0eccea90
```

## Usage
Deploy the contracts
```
sui client publish --gas-budget 20000000
```
Change the fields in `.env` and run
```
cargo run
```
