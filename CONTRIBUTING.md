# Contributing

We love pull requests from everyone. By participating in this project, you
agree to abide by our [code of conduct](https://github.com/restforce/restforce/blob/master/CODE_OF_CONDUCT.md).

Fork, then clone the repo:

    git clone git@github.com:restforce/restforce.git

Set up your machine:

    script/bootstrap

Play with the library by starting a console:

    script/console

Make sure the tests pass:

    script/test

Make your change. Add tests for your change. Make the tests pass:

    script/test

Push to your fork and [submit a pull request](https://github.com/restforce/restforce/compare/).

At this point you're waiting on us. We like to at least comment on pull requests
within a few days. We may suggest
some changes or improvements or alternatives.

Some things that will increase the chance that your pull request is accepted:

* Write tests.
* Write a [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

*Adapted from [factory_bot_rails's CONTRIBUTING.md](https://github.com/thoughtbot/factory_bot_rails/blob/master/CONTRIBUTING.md).*

## Docker

If you'd rather use a docker container to run the tests, you can use the following instructions.

To set up the container image:

`docker-compose build --pull`

To run specs:

`docker-compose run --rm restforce rspec`

To run rubocop:

`docker-compose run --rm restforce rubocop`

To reset the bundler cache:

`docker-compose down -v`
