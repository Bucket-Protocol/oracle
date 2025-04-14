import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { private_key } from "./env.json";

export const signer = Ed25519Keypair.fromSecretKey(private_key);
