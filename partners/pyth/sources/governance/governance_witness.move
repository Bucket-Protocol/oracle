module pyth_local::governance_witness {

    friend pyth_local::set_data_sources;
    friend pyth_local::set_stale_price_threshold;
    friend pyth_local::set_update_fee;
    friend pyth_local::set_governance_data_source;
    friend pyth_local::set_fee_recipient;
    friend pyth_local::contract_upgrade;

    /// A hot potato that ensures that only DecreeTickets
    /// and DecreeReceipts associated with Sui Pyth governance
    /// are passed to execute_governance_instruction or
    /// execute_contract_upgrade_governance_instruction.
    ///
    /// DecreeTickets and DecreeReceipts are Wormhole structs
    /// that are used in the VAA verification process.
    struct GovernanceWitness has drop {}

    public(friend) fun new_governance_witness(): GovernanceWitness{
        GovernanceWitness{}
    }
}
