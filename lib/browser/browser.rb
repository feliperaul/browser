# frozen_string_literal: true

require "set"
require "yaml"
require "pathname"

require_relative "version"
require_relative "detect_version"
require_relative "accept_language"
require_relative "base"
require_relative "safari"
require_relative "chrome"
require_relative "internet_explorer"
require_relative "firefox"
require_relative "edge"
require_relative "opera"
require_relative "blackberry"
require_relative "generic"
require_relative "phantom_js"
require_relative "uc_browser"
require_relative "nokia"
require_relative "micro_messenger"
require_relative "weibo"
require_relative "qq"
require_relative "alipay"
require_relative "electron"
require_relative "facebook"
require_relative "otter"
require_relative "instagram"
require_relative "yandex"
require_relative "sputnik"
require_relative "snapchat"

require_relative "bot"
require_relative "middleware"
require_relative "platform"
require_relative "device"
require_relative "meta"

module Browser
  EMPTY_STRING = ""

  def self.root
    @root ||= Pathname.new(File.expand_path("../..", __dir__))
  end

  # Hold the list of browser matchers.
  # Order is important.
  def self.matchers
    @matchers ||= [
      Nokia,
      UCBrowser,
      PhantomJS,
      BlackBerry,
      Opera,
      Edge,
      InternetExplorer,
      Firefox,
      Otter,
      Facebook,             # must be placed before Chrome and Safari
      Instagram,            # must be placed before Chrome and Safari
      Snapchat,             # must be placed before Chrome and Safari
      Weibo,                # must be placed before Chrome and Safari
      QQ,                   # must be placed before Chrome and Safari
      Alipay,               # must be placed before Chrome and Safari
      Electron,             # must be placed before Chrome and Safari
      Yandex,               # must be placed before Chrome and Safari
      Sputnik,              # must be placed before Chrome and Safari
      Chrome,
      Safari,
      MicroMessenger,
      Generic
    ]
  end

  # Define the rules which define a modern browser.
  # A rule must be a proc/lambda or any object that implements the method
  # === and accepts the browser object.
  #
  # To redefine all rules, clear the existing rules before adding your own.
  #
  #   # Only Chrome Canary is considered modern.
  #   Browser.modern_rules.clear
  #   Browser.modern_rules << -> b { b.chrome? && b.version >= "37" }
  #
  def self.modern_rules
    @modern_rules ||= []
  end

  modern_rules.tap do |rules|
    rules << ->(b) { b.chrome? && b.version.to_i >= 65 }
    rules << ->(b) { b.safari? && b.version.to_i >= 10 }
    rules << ->(b) { b.firefox? && b.version.to_i >= 52 }
    rules << ->(b) { b.ie? && b.version.to_i >= 11 && !b.compatibility_view? }
    rules << ->(b) { b.edge? && b.version.to_i >= 39 && !b.compatibility_view? }
    rules << ->(b) { b.opera? && b.version.to_i >= 50 }
  end

  def self.new(user_agent, **kwargs)
    matchers
      .map {|klass| klass.new(user_agent || EMPTY_STRING, **kwargs) }
      .find(&:match?)
  end
end
