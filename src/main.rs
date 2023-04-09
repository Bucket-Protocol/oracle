use sui::client_commands::{WalletContext, call_move};
// use sui::config;
use anyhow::{Result, anyhow};
use tokio::{time, task};
use binance::api::Binance;
use binance::market::Market;

#[tokio::main]
async fn main() -> Result<()> {
    let sui_config_path = dirs::home_dir()
        .expect("Failed to get home dir")
        .join(".sui").join("sui_config").join("client.yaml");
    println!("sui client config: {:?}", &sui_config_path);
    let mut wallet = WalletContext::new(&sui_config_path, None)
        .await
        .or(Err(anyhow!("Failed to get wallet context")))?;
    let active_address = wallet
        .active_address()
        .or(Err(anyhow!("Failed to get active address")))?;
    println!("active address: {:?}", active_address);

    let forever = task::spawn(async {
        let mut interval = time::interval(time::Duration::from_secs(10));
        let market: Market = Binance::new(None, None);
        loop {
            interval.tick().await;
            if let Ok(resp) = market.get_price("BTCUSDT").await {
                let price_u64 = (resp.price * 1_000.0) as u64;
            };
        }
    });

    forever.await?;
    Ok(())
}