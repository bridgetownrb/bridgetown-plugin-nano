# bridgetown-plugin-nano
One-step commands to install and configure a Rails-based Nano API backend for Bridgetown

**Coming in Q1 2021!**

## Installation

Run this command to add this plugin to your site's Gemfile:

```shell
$ bundle add bridgetown-plugin-nano -g bridgetown_plugins
```

## Usage

```shell
$ bundle exec bridgetown nano new
```

To deploy to production you'll need a `SECRET_KEY_BASE` env var. You can generate one with this command:

```shell
$ bundle exec bridgetown nano exec secret
```

## Testing

* Run `bundle exec rake` to run the test suite
* Or run `script/cibuild` to validate with Rubocop and test together.

## Contributing

1. Fork it (https://github.com/bridgetownrb/bridgetown-nano-plugin/fork)
2. Clone the fork using `git clone` to your local development machine.
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
