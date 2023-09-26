# Bucket Oracle
Aggregate price from Switchboard, Pyth and Supra on Sui.

## Testnet
Package ID
```
0x06dec2d93d91558ef917053673762e44fafac9c999fdeea29b5e6105ad7df246
```
Bucket Oracle ID, init_shared_version: `274`
```
0xf6db6a423e8a2b7dea38f57c250a85235f286ffd9b242157eff7a4494dffc119
```
AdminCap
```
0xbf0ffa69d96e4042c436e812a4b691c8555e70e073ff5639c211eea122197248
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
