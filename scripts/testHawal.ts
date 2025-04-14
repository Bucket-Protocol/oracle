import { BucketClient } from "bucket-protocol-sdk";
import { Transaction } from "@mysten/sui/transactions";

const main = async()=>{
    const client = new BucketClient();
    const tx = new Transaction();

    client.updateSupraOracle(tx, "WAL");
    
}


main()