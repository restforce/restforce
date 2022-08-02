# frozen_string_literal: true

# In our tests, we test some Faraday internals to make sure that the package
# is working as expected. Some of those internals differ between v0.x and v1.x
# onwards. To make things confusing, v0.16.x introduced some 1.x-style breaking
# changes, so we treat that version like v1.x 🤷‍♂️ See
# https://github.com/lostisland/faraday/releases/tag/v0.17.0.
def faraday_before_first_major_version?
  Faraday::VERSION =~ /\A0\./ && !Faraday::VERSION.start_with?("0.16")
end
