import { BucketClient } from "bucket-protocol-sdk";
import { Transaction } from "@mysten/sui/transactions";
import { signer } from "./config";

const main = async () => {
  const client = new BucketClient();
  const tx = new Transaction();

  tx.moveCall({
    target:
      "0xb41200d83cbf268281c170c0ade226a50a22f3901c43d08f6c167a7ddc8061f9::stsbuck_rule::update_price",
    arguments: [
      tx.object(
        "0xf578d73f54b3068166d73c1a1edd5a105ce82f97f5a8ea1ac17d53e0132a1078",
      ),
      tx.object("0x6"),
      tx.object(
        "0xe83e455a9e99884c086c8c79c13367e7a865de1f953e75bcf3e529cdf03c6224",
      ),
    ],
  });

  const res = await client.getSuiClient().signAndExecuteTransaction({
    transaction: tx,
    signer,
  });
  console.log(res.digest);
};

main().catch((err) => console.log(err));
