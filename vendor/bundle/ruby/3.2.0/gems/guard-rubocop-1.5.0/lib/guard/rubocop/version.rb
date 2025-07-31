# frozen_string_literal: true

# A workaround for declaring `class RuboCop`
# before `class RuboCop < Guard` in rubocop.rb
module GuardRuboCopVersion
  # http://semver.org/
  MAJOR = 1
  MINOR = 5
  PATCH = 0

  def self.to_s
    [MAJOR, MINOR, PATCH].join('.')
  end
end
