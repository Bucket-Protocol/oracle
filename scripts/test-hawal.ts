import { BucketClient } from "bucket-protocol-sdk";
import { Transaction } from "@mysten/sui/transactions";
import { signer } from "./config";
import { HAWAL_RULE_PKG_ID, BUKCET_ORACLE_OBJECT_ID, WALRUS_STAKING_OBJECT_ID } from "./constant";

const main = async () => {
  const client = new BucketClient();
  const tx = new Transaction();

  client.updateSupraOracle(tx, "WAL");

  tx.moveCall(
    {
        package: HAWAL_RULE_PKG_ID,
        module: "hawal_rule",
        function: "update_price",
        arguments: [
            tx.object(BUKCET_ORACLE_OBJECT_ID),
            tx.object(WALRUS_STAKING_OBJECT_ID),
            tx.object("0x6"),
        ]
    }
  );
  const res = await client.getSuiClient().signAndExecuteTransaction({
    transaction: tx,
    signer,
  });
  console.log(res.digest);
};

main().catch((err) => console.log(err));
