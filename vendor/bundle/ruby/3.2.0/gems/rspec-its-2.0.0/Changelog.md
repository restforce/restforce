### 2.0.0 / 2024-11-04

Version 2.0.0 drops support for Ruby below 3, and changes the supported RSpec version to "main" and current release series.
(At the time of writing this is 3.13.x, but it means the current supported release only).

Breaking changes:

* Now uses `public_send` so that private methods will not be accidentally reachable. (James Ottaway #33, #101)

### 1.3.1 / 2024-10-23
[full changelog](http://github.com/rspec/rspec-its/compare/v1.3.0...v1.3.1)

Bug fixes:

* Prevent overridden `example` methods causing issues by creating our own
  Example Group creation alias `__its_example`. (Jon Rowe, #95)

### 1.3.0 / 2019-04-09
[full changelog](http://github.com/rspec/rspec-its/compare/v1.2.0...v1.3.0)

Enhancements:
* Introduced `will` and `will_not` as to allow one line block expectations.
  (Russ Buchanan, #67)

### 1.2.0 / 2015-02-06
[full changelog](http://github.com/rspec/rspec-its/compare/v1.1.0...v1.2.0)

Breaking Changes:

Enhancements:
* Introduced `are_expected` as alias for `is_expected`

Bug fixes:
* Restored ability to pass key/value metadata parameters, broken by https://github.com/rspec/rspec-its/commit/71307bc7051f482bfc2798daa390bee9142b0d5a

### 1.1.0 / 2014-04-13
[full changelog](http://github.com/rspec/rspec-its/compare/v1.0.1...v1.1.0)

Breaking Changes:

Enhancements:
* For hashes, multiple array elements are treated as successive access keys
* Metadata arguments are now supported

Bug fixes:
* Enable `its` example selection by line number in command line


### 1.0.1 / 2014-04-13
[full changelog](http://github.com/rspec/rspec-its/compare/v1.0.0...v1.0.1)

Bug fixes:
* Maintain implicit subject in all cases (addresses problem with latest RSpec 3 version)

### 1.0.0 / 2014-02-07
[full changelog](http://github.com/rspec/rspec-its/compare/v1.0.0.pre...v1.0.0)

Breaking Changes:

Enhancements:
* Add `is_expected` support to match RSpec 3.0

Deprecations:

Bug Fixes:
* Report failures and backtrace from client perspective

### 1.0.0.pre / 2013-10-11

Features

* Initial extraction of `its()` functionality to separate gem

