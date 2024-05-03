module oracle::oracle {

    use aptos_std::math64;

    use amnis::stapt_token::stapt_price;

    use pyth::i64;
    use pyth::price_identifier;
    use pyth::pyth;

    const PRECISION: u64 = 100000000;
    const APT_IDS: vector<u8> = x"03ae4db29ed4ae33d323568895aa00337e658e348b37509f5372ae51f0af00d5";


    public fun get_pyth_price(price_id: vector<u8>): u64 {
        let price_identifier = price_id;
        let price_id = price_identifier::from_byte_vec(price_identifier);
        let price = pyth::get_price(price_id);
        let expo = pyth::price::get_expo(&price);
        let raw_price = i64::get_magnitude_if_positive(&pyth::price::get_price(&price));
        (raw_price * PRECISION) / math64::pow(10, pyth::i64::get_magnitude_if_negative(&expo))
    }

    public fun get_pyth_price_no_older(price_id: vector<u8>, max_age_secs: u64): u64 {
        let price_identifier = price_id;
        let price_id = price_identifier::from_byte_vec(price_identifier);
        let price = pyth::get_price_no_older_than(price_id, max_age_secs);
        let raw_price = i64::get_magnitude_if_positive(&pyth::price::get_price(&price));
        let expo = pyth::price::get_expo(&price);
        (raw_price * PRECISION) / math64::pow(10, pyth::i64::get_magnitude_if_negative(&expo))
    }

    #[view]
    public fun apt_usd_price(): u64 {
        get_pyth_price(
            APT_IDS
        )
    }

    #[view]
    public fun stapt_usd_price(): u64 {
        let apt_price = apt_usd_price();
        let stapt_apt_rate = stapt_price();
        (((apt_price as u128) * (stapt_apt_rate as u128) / (PRECISION as u128)) as u64)
    }
}
