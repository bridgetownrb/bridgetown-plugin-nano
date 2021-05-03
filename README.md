# May 2021 Update:

I've decided to suspend work on a Rails-specific integration for Bridgetown until further notice. Bridgetown does currently have an [outstanding PR for switching to Puma/Rack/Roda](https://github.com/bridgetownrb/bridgetown/pull/281) for essential routes, and you absolutely can mount a Rails API right onto that however you wish. But [in light](https://solnic.codes/2021/05/01/whoops-thoughts-on-rails-forking-and-leadership/) of [recent events](https://www.theverge.com/2021/4/30/22412714/basecamp-employees-memo-policy-hansson-fried-controversy), I will not personally be working on a Rails integration solution.

----

# bridgetown-plugin-nano (WIP)

One-step commands to install and configure a Rails-based Nano API backend for Bridgetown

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
