# frozen_string_literal: true

#
# Taken from v1.1.0 of Faraday in order to fix Faraday v1.0.x in modern
# Ruby versions. In v1.0.x, the argument definitions for `#new` are
# problematic. See
# <https://github.com/lostisland/faraday/blob/v1.1.0/lib/faraday/dependency_loader.rb>.
#
# Copyright (c) 2009-2022 Rick Olson, Zack Hobson
# Licensed under the MIT License.
#
require 'ruby2_keywords'

module Faraday
  module DependencyLoader
    ruby2_keywords def new(*)
      raise "missing dependency for #{self}: #{load_error.message}" unless loaded?

      super
    end
  end
end
