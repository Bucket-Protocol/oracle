import { BucketClient, CLOCK_OBJECT, ORACLE_OBJECT } from "bucket-protocol-sdk";
import { Transaction } from "@mysten/sui/transactions";
import { signer } from "./config";

const main = async () => {
  const client = new BucketClient();
  const tx = new Transaction();

  tx.moveCall({
    target: `0x1f19c4572c45f8e116a6aa6c7ffafc3569a3cea407ad839c43de5898369030ce::tlp_rule::update_price`,
    typeArguments: [
      "0xe27969a70f93034de9ce16e6ad661b480324574e68d15a64b513fd90eb2423e5::tlp::TLP",
    ],
    arguments: [
      tx.object(
        "0x55597bb70d150f4a72223e04a11b2211918ea5ed3d485a7dcb06e490ae21f7d9",
      ),
      tx.sharedObjectRef(ORACLE_OBJECT),
      tx.sharedObjectRef(CLOCK_OBJECT),
      tx.object(
        "0xa12c282a068328833ec4a9109fc77803ec1f523f8da1bb0f82bac8450335f0c9",
      ),
      tx.object(
        "0xfee68e535bf24702be28fa38ea2d5946e617e0035027d5ca29dbed99efd82aaa",
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
