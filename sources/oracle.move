module oracle::oracle {
    use amnis::stapt_token::stapt_price;

    use pyth::i64::get_magnitude_if_positive;
    use pyth::price::{get_price, Price};
    use pyth::price_identifier;
    use pyth::pyth;

    const ONE_COIN: u64 = 100000000;
    const APT_IDS: vector<u8> = x"03ae4db29ed4ae33d323568895aa00337e658e348b37509f5372ae51f0af00d5";


    public fun ex_get_price(adr: vector<u8>): Price {
        let btc_price_identifier = adr;
        // Now we can use the prices which we have just updated
        let price_id = price_identifier::from_byte_vec(btc_price_identifier);
        pyth::get_price(price_id)
    }


    #[view]
    public fun get_price_entry(pool_address: vector<u8>): u64 {
        let price = ex_get_price(pool_address) ;
        get_magnitude_if_positive(&get_price(&price))
    }


    #[view]
    public fun apt_usd_price(): u64 {
        get_price_entry(
            APT_IDS
        )
    }

    #[view]
    public fun stapt_apt_rate(): u64 {
        stapt_price()
    }

    #[view]
    public fun stapt_usd_price(): u64 {
        let apt_price = apt_usd_price();
        let stapt_apt_rate = stapt_price();
        (((apt_price as u128) * (stapt_apt_rate as u128) / (ONE_COIN as u128)) as u64)
    }
}
