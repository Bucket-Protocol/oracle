import { BucketClient } from "bucket-protocol-sdk";
import { Transaction } from "@mysten/sui/transactions";
import { signer } from "./config";

const main = async () => {
  const client = new BucketClient();
  const tx = new Transaction();

  client.updateSupraOracle(tx, "WAL");

  /// TODO: update haWAL price
  // tx.moveCall({
  //
  // })
  //
  const res = await client.getSuiClient().signAndExecuteTransaction({
    transaction: tx,
    signer,
  });
  console.log(res.digest);
};

main().catch((err) => console.log(err));
