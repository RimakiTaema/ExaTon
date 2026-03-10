use openapi::apis::configuration::Configuration;

pub fn make_config(token: &str) -> Configuration {
    Configuration {
        bearer_access_token: Some(token.to_owned()),
        ..Configuration::default()
    }
}
