# frozen_string_literal: true

require "test_helper"

class AttrEncrypter::AccessorsTest < Minitest::Test
  include TestHelpers

  def encrypted_instance
    klass = Class.new do
      attr_accessor :token_digest
      include AttrEncrypter::Accessors
      @keychain = AttrEncrypter::AccessorsTest::KEY_1
      attr_encrypter @keychain, :token
    end

    instance       = klass.new
    instance.token = DATA
    instance
  end

  test "nil" do
    instance       = encrypted_instance
    instance.token = nil

    assert_nil instance.token
    assert_nil instance.token_digest
  end

  test "encrypt/decrypt with key 1" do
    instance = encrypted_instance

    assert_equal DATA, instance.token
    assert_match digest_format(1), instance.token_digest
  end

  test "encrypt with the latest key (2)" do
    klass = Class.new do
      attr_accessor :token_digest
      include AttrEncrypter::Accessors
      @keychain = [AttrEncrypter::AccessorsTest::KEY_1,
                   AttrEncrypter::AccessorsTest::KEY_2].join(" ")
      attr_encrypter @keychain, :token
    end

    instance       = klass.new
    instance.token = DATA
    assert_equal DATA, instance.token
    assert_match digest_format(2), instance.token_digest
  end

  test "upgrade from key 1 to key 3 (latest)" do
    klass = Class.new do
      attr_accessor :token_digest
      include AttrEncrypter::Accessors
      @keychain = [AttrEncrypter::AccessorsTest::KEY_1,
                   AttrEncrypter::AccessorsTest::KEY_2,
                   AttrEncrypter::AccessorsTest::KEY_3].join(" ")
      attr_encrypter @keychain, :token
    end

    instance_1              = encrypted_instance
    instance_2              = klass.new
    instance_1.token        = DATA
    instance_2.token_digest = instance_1.token_digest

    assert_match digest_format(1), instance_2.token_digest
    assert_equal DATA, instance_2.token

    instance_2.token = instance_2.token

    assert_match digest_format(3), instance_2.token_digest
    assert_equal DATA, instance_2.token
  end
end
