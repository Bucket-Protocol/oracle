# Bucket Oracle
Aggregate price from Switchboard, Pyth and Supra on Sui.

## Testnet
Package ID, init_shared_version: `37`
```
0xbc95dfa4450cd360868addde709c60875eeb667c59d47ed7811880776adf96fb
```
Oracle Object ID, init_shared_version: `37`
```
0xff459a65463a4ed60f722b1e188092ca51dc51149c90827df37392fe09105eef
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
