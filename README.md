# Silverpop::Client

Ruby client for IBM Silverpop Engage and Transact API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'silverpop-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install silverpop-client

## Usage

```ruby
gem 'silverpop-client'
options = {
        client_id: SILVERPOP_CLIENT_ID,
        client_secret: SILVERPOP_CLIENT_SECRET,
        refresh_token: REFRESH_TOKEN,
        xmlapi_url: 'https://api[x].silverpop.com/XMLAPI',
        xtmail_url: 'https://transact[x].silverpop.com/XTMail',
        auth_url: 'https://api[x].silverpop.com/oauth/token'
}
@client = Silverpop::Client.new(@options)
```

You can then call the API via the methods of Silverpop::Client.
The required API params are required by the methods, optional parameters can be specified by the options hash.

To call GetJobStats:

```
@client.get_job_stats(JOB_ID)
```

## Contributing

1. Fork it ( https://github.com/500friends/silverpop-client/fork )
2. Create your feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a new Pull Request
