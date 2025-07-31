# Upgrading from Restforce 7.x to 8.x

## Ruby 3.0 is no longer supported

**Likelyhood of impact**: Moderate

Ruby 3.0 is no longer officially supported as an active version of the Ruby language. That means that it will not receive patches and security fixes.

Accordingly, we've dropped support for Ruby 3.0 in the Restforce library. The gemspec now specifies that only 3.1 onwards is supported, and this will be enforced by RubyGems.

Before you update to Restforce 8.x, you'll need to switch to Ruby 3.1.0 or later. The current version of Ruby at the time of writing is 3.4.5.

# Upgrading from Restforce 6.x to 7.x

## Ruby 2.7 is no longer supported

__Likelyhood of impact__: Moderate

Ruby 2.7 is no longer officially supported as an active version of the Ruby language. That means that it will not receive patches and security fixes.

Accordingly, we've dropped support for Ruby 2.7 in the Restforce library. The gemspec now specifies that only 3.0 onwards is supported, and this will be enforced by RubyGems.

Before you update to Restforce 7.x, you'll need to switch to Ruby 3.0.0 or later. The current version of Ruby at the time of writing is 3.2.2.

# Upgrading from Restforce 5.x to 6.x

__There are two breaking changes introduced in Restforce 6.x__. In this guide, you'll learn about these changes and what you should check in your code to make sure that it will work with the latest version of the library.

## Versions of `faraday` before `v1.1.0` are no longer supported

__Likelyhood of impact__: Moderate

Restforce uses a gem called [`faraday`](https://github.com/lostisland/faraday) to make HTTP requests to Salesforce. 

Up until now, Restforce has supported Faraday versions between v0.9.0 and v1.10.0. 

In Restforce 6.x, we drop support for Faraday versions before v1.1.0, and add support for Faraday v2.x.

This will allow you to use the latest versions of Faraday and benefit from security patches, new features, etc., but you may need to adapt your code. The impact of this change will depend on your project:

* If Restforce is the only part of your project using Faraday - that is, your own code doesn't use Faraday and none of your other gems use Faraday - then you shouldn't need to do anything special. Just upgrade Restforce, and everything should be handled automatically.
* If your own code uses Faraday or another gem you use depends on Faraday, and you're currently using a Faraday version before v1.1.0, you will need to upgrade your Faraday version. If possible, you should upgrade to the latest version (v2.4.0 at the time of writing). This may require you to adapt your code (see [here](https://github.com/lostisland/faraday/blob/main/UPGRADING.md) for Faraday's instructions) or upgrade other gems you depend on.

## Ruby 2.6 is no longer supported

__Likelyhood of impact__: Moderate

Ruby 2.6 is no longer officially supported as an active version of the Ruby language. That means that it will not receive patches and security fixes.

Accordingly, we've dropped support for Ruby 2.6 and earlier in the Restforce library. The gemspec now specifies that only 2.7 onwards is supported, and this will be enforced by RubyGems.

Before you update to Restforce 6.x, you'll need to switch to Ruby 2.7 or later. The current version of Ruby at the time of wriing is 3.1.

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