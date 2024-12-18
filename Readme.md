# Dispatch

Ruby app for reading latest updates from several package managers as well as GitHub:

* Hex
* Hackage
* CPAN
* Pub

## Development

Source hosted at [GitHub](http://github.com/librariesio/dispatch).
Report issues/feature requests on [GitHub Issues](http://github.com/librariesio/dispatch/issues).

### Getting Started

* Install Ruby 3.2.3
* `bundle install`
* `bundle exec rake` and tests should pass

### Testing

* `bundle exec rake` for RSpec tests
* `bundle exec lint` for RuboCop
  * There's still some linting to fix or rules to change
* `docker-compose build && docker-compose up` to test the server for real

### Docker

`docker build -t librariesio-dispatch .` to ensure docker builds work correctly.

### Note on Patches/Pull Requests

 * Fork the project.
 * Make your feature addition or bug fix.
 * Add tests.
 * Add documentation.
 * Commit, do not change procfile or history.
 * Send a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2017 Andrew Nesbitt, 2024 Tidelift. See [LICENSE](https://github.com/librariesio/dispatch/blob/master/LICENSE) for details.
