# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "simplecov"
SimpleCov.start

module TestHelpers
  KEY_1 = "1.0ac65d409b9354741eecdb2d911cf6a65f3bf57a41f98265d126d46e17894e39".freeze
  KEY_2 = "2.a3bacb5fe932c3eb484618a23f34869603b68edb5409f486eec57bbbf05b74cd".freeze
  KEY_3 = "3.d5582aa81329088caad85c11966bcda146f3fa27fd4f50d6523c917fafc789b2".freeze
  DATA  = "example".freeze

  module InstanceMethods
    def key_format(version)
      /^#{version}\.[0-9a-f]{64}$/
    end

    def digest_format(version)
      /^#{version}\.([a-zA-Z0-9\+\=\n\/]+)$/
    end
  end

  module ClassMethods
    def test(name, &block)
      definition = "test_#{name.downcase.gsub(" ", "_")}"

      define_method definition do
        instance_eval(&block)
      end
    end
  end

  def self.included(klass)
    klass.send(:include, InstanceMethods)
    klass.extend(ClassMethods)
  end
end

require "attr_encrypter"
require "minitest/autorun"
