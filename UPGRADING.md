# Upgrading from Restforce 4.x to 5.x

__There are three breaking changes introduced in Restforce 5.x__. In this guide, you'll learn about these changes and what you should check in your code to make sure that it will work with the latest version of the library.

## Error classes are now defined up-front, rather than dynamically at runtime

__Likelyhood of impact__: Moderate

The Salesforce REST API can return a range of `errorCode`s representing different kinds of errors. To make these easy to
handle in your code, we want to turn these into individual, specific exception classes in the `Restforce::ErrorCode` namespace that inherit from `Restforce:: ResponseError`.

Up until now, these exception classes have been defined dynamically at runtime which has some disadvantages - see the [pull request](https://github.com/restforce/restforce/pull/551) for more details.

In this version, we switch to defining them up-front in the code based on a list in the Salesforce documentation. There is a risk that we might have missed some errors which should be defined. If any errors are missed, they will be added in patch versions (e.g. `5.0.1`). 

If your application won't run because you are referring to an exception class that no longer exists, or you see warnings logged anywhere, please [create an issue](https://github.com/restforce/restforce/issues/new?template=unhandled-salesforce-error.md&title=Unhandled+Salesforce+error%3A+%3Cinsert+error+code+here%3E).

## Ruby 2.4 is no longer supported

__Likelyhood of impact__: Moderate

As of [5th April 2020](https://www.ruby-lang.org/en/news/2020/04/05/support-of-ruby-2-4-has-ended/), Ruby 2.4 is no longer officially supported as an active version of the Ruby language. That means that it will not receive patches and security fixes.

Accordingly, we've dropped support for Ruby 2.4 and earlier in the Restforce library. It *may* be compatible, bu we don't guarantee this or enforce it with automated tests.

Before you update to Restforce 5.x, you'll need to switch to Ruby 2.5 or later. The current version of Ruby at the time of wriing is 2.7.

## `Restforce::UnauthorizedError` no longer inherits from `Restforce::Error`

__Likelyhood of impact__: Low

Previously, the `Restforce::UnauthorizedError` returned when the library couldn't authenticate with the Salesforce API inherits from `Restforce::Error`. So, if you used `rescue Restforce::Error` in your code, you'd catch these exceptions.

We've now changed this exception class to inherit from `Faraday::ClientError` which allows the response body returned from the Salesforce API to be attached to the error.

If you refer to `Restforce::Error` anywhere in your code, you should check whether you also need to take into account `Restforce::UnauthorizedError`.

If you refer to `Faraday::ClientError` anywhere in your code, you should check that you want the case where Restforce can't authenticate to be included.