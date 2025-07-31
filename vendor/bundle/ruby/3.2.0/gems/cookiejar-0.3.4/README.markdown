Ruby CookieJar
==============

  **Git**:	[http://github.com/dwaite/cookiejar](http://github.com/dwaite/cookiejar)

  **Author**:	David Waite 

[![Build Status](https://travis-ci.org/dwaite/cookiejar.svg?branch=master)](https://travis-ci.org/dwaite/cookiejar)

Status
------

This project is no longer maintained. There may be other gems more appropriate for use which support newer versions of the cookie specifications, or more maintained forks of this gem such as [cookiejar2](https://github.com/dorianmariefr/cookiejar2).

Synopsis
--------

The Ruby CookieJar is a library to help manage client-side cookies in pure Ruby. It enables parsing and setting of cookie headers, alternating between multiple 'jars' of cookies at one time (such as having a set of cookies for each browser or thread), and supports persistence of the cookies in a JSON string.

Both Netscape/RFC 2109 cookies and RFC 2965 cookies are supported.

Roadmap
-------

For the Next major release, I would like to accomplish:

1. Check against [RFC 6265 - HTTP State Management Mechanism][rfc6265], the latest cookie spec which came out after the initial release of cookiejar
2. Determine better code structure to encourage alternate persistence mechanisms for cookie jars

[rfc6265]: http://tools.ietf.org/html/rfc6265
COPYRIGHT
---------
The Ruby CookieJar is Copyright &copy; 2009-2014 David Waite, with [additional contributions from various authors][contributions]. Licensing terms are given within the [LICENSE file][LICENSE].

[contributions]: ./contributors.json
[LICENSE]: ./LICENSE
