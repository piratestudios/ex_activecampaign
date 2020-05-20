# ex_activecampaign

A elixir middleware library for interfacing with the
[ActiveCampaign API](https://developers.activecampaign.com/reference).

## Installation

The package can be installed by adding `ex_activecampaign` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_activecampaign, github: "piratestudios/ex_activecampaign"}
  ]
end
```

Once added, run mix `deps.get`

## Configuration

You will need to set the following configuration variables in your
`config/config.exs` file:

```elixir
use Mix.Config

config :ex_activecampaign, base_url:  "https://<your-account>.api-us1.com/api/3",
                           api_token: "YOUR-ACTIVECAMPAIGN-TOKEN"
```

### Multiple Environments
If you want to use different ActiveCampaign credentials for different environments, then create separate Mix
configuration files for each environment. To do this, change `config/config.exs` to look like this:

```elixir
# config/config.exs

use Mix.Config

# shared configuration for all environments here ...

import_config "#{Mix.env}.exs"
```

Then, create a `config/#{environment_name}.exs` file for each environment. You can then set the
`config :ex_activecampaign` variables differently in each file.

## Usage

To use the middleware, simply add a call to the desired API method in the relevant part of the dependent codebase, e.g.:

```
def email_signup(email, first_name, last_name, phone) do
    ExActivecampaign.Contact.create(%{contact: %{email: email, firstName: first_name, lastName: last_name, phone: phone}})
end
```

### Supported Endpoints

Currently only supports requests to the following endpoints of the ActiveCampaign
[Contacts](https://developers.activecampaign.com/reference#contact) API:
- [Create a contact](https://developers.activecampaign.com/reference#create-contact) -
`ExActiveCampaign.Contact.create()`
- [Create or update contact](https://developers.activecampaign.com/reference#create-contact-sync) -
`ExActiveCampaign.Contact.create_or_update()`
- [Retrieve a contact](https://developers.activecampaign.com/reference#get-contact) -
`ExActiveCampaign.Contact.retrieve()`
- [Update list status for a contact](https://developers.activecampaign.com/reference#update-list-status-for-contact) -
`ExActiveCampaign.Contact.update_list_status()`