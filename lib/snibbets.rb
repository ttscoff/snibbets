# frozen_string_literal: true

require 'optparse'
require 'readline'
require 'json'
require 'cgi'
require 'shellwords'
require 'yaml'
require 'fileutils'
require 'tty-which'
require_relative 'snibbets/version'
require_relative 'snibbets/config'
require_relative 'snibbets/which'
require_relative 'snibbets/string'
require_relative 'snibbets/hash'
require_relative 'snibbets/menu'
require_relative 'snibbets/os'
require_relative 'snibbets/highlight'
require_relative 'snibbets/lexers'

# Top level module
module Snibbets
  class << self
    def config
      @config ||= Config.new
    end

    def options
      @options = config.options
    end
  end
end
