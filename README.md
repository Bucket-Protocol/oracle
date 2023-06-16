# Bucket Oracle
Aggregate price from Switchboard, Pyth and Supra on Sui.

## Testnet
Package ID
```
0x5ade547fc4816c9f2c9d7cf8f9223c9ba491755b845fb2a3507415077eea9110
```
Bucket Oracle ID, init_shared_version: `273`
```
0x1c12e3ef3b1a3de13a9fcb881aa91362de9af1fb22a4a037a11835fcbc500e64
```

## Usage
Deploy the contracts
```
sui client publish --gas-budget 20000000 --skip-dependency-verification
```
Change the fields in `.env` and run
```
cargo run
```
