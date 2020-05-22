# ExActivecampaign

A elixir middleware library for interfacing with the
[ActiveCampaign API](https://developers.activecampaign.com/reference).

## Installation

The package can be installed by adding `ex_activecampaign` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_activecampaign, git: "git@github.com:piratestudios/ex_activecampaign.git", tag: "0.1.5"}
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

```elixir
def subscribe_to_mailing_list(email, first_name, last_name, phone) do
    %{contact: %{id: id}} = ExActivecampaign.Contact.create_or_update(
        %{email: email, first_name: first_name, last_name: last_name, phone: phone}
    )
    ExActivecampaign.Contact.update_list_status(
        %{contact: id, list: 1, status: 1}
    )
end
```

### Supported Endpoints

ExActivecampaign currently supports requests to the following endpoints of the ActiveCampaign API

#### [Contacts](https://developers.activecampaign.com/reference#contact):
- [Create a contact](https://developers.activecampaign.com/reference#create-contact) -
`ExActiveCampaign.Contact.create()`
- [Create or update contact](https://developers.activecampaign.com/reference#create-contact-sync) -
`ExActiveCampaign.Contact.create_or_update()`
- [Retrieve a contact](https://developers.activecampaign.com/reference#get-contact) -
`ExActiveCampaign.Contact.retrieve()`
- [Update list status for a contact](https://developers.activecampaign.com/reference#update-list-status-for-contact) -
`ExActiveCampaign.Contact.update_list_status()`

#### [Lists](https://developers.activecampaign.com/reference#lists):
- [Retrieve a list](https://developers.activecampaign.com/reference#retrieve-a-list) -
`ExActiveCampaign.List.retrieve()`