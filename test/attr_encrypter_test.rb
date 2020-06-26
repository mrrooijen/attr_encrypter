# frozen_string_literal: true

require "test_helper"

class TestAttrEncrypter < Minitest::Test
  include TestHelpers

  test "initialize with nil" do
    assert_raises(AttrEncrypter::Errors::NoKeychainError) { AttrEncrypter.new(nil) }
  end

  test "initialize with blank string" do
    assert_raises(AttrEncrypter::Errors::NoKeychainError) { AttrEncrypter.new(" \n") }
  end

  test "generate initial key" do
    assert_match key_format(1), AttrEncrypter::Generator.generate_key
  end

  test "generate second key" do
    assert_match key_format(2), AttrEncrypter::Generator.generate_key(2)
  end

  test "encrypt with key 1" do
    attr_encrypter = AttrEncrypter.new(KEY_1)
    digest         = attr_encrypter.encrypt(DATA)
    raw            = attr_encrypter.decrypt(digest)

    assert_match digest_format(1), digest
    assert_equal DATA, raw
  end

  test "upgrade from key 1 to latest key (2)" do
    attr_encrypter = AttrEncrypter.new([KEY_1, KEY_2].join(" "))
    digest_1       = attr_encrypter.encrypt(DATA)
    attr_encrypter = AttrEncrypter.new([KEY_1, KEY_2].join(" "))
    raw_1          = attr_encrypter.decrypt(digest_1)
    digest_2       = attr_encrypter.encrypt(raw_1)
    raw_2          = attr_encrypter.decrypt(digest_2)

    assert_match digest_format(2), digest_2
    assert_equal DATA, raw_2
  end

  test "upgrade from key 1 to latest key (3)" do
    attr_encrypter = AttrEncrypter.new(KEY_1)
    digest_1       = attr_encrypter.encrypt(DATA)
    attr_encrypter = AttrEncrypter.new([KEY_1, KEY_2, KEY_3].join(" "))
    raw_1          = attr_encrypter.decrypt(digest_1)
    digest_2       = attr_encrypter.encrypt(raw_1)
    raw_2          = attr_encrypter.decrypt(digest_2)

    assert_match digest_format(3), digest_2
    assert_equal DATA, raw_2
  end

  test "initialize with spaces, tabs and new lines in keychain" do
    attr_encrypter = AttrEncrypter.new([KEY_1, KEY_2, KEY_3].join("\s\n\t"))
    digest         = attr_encrypter.encrypt(DATA)
    raw            = attr_encrypter.decrypt(digest)

    assert_match digest_format(3), digest
    assert_equal DATA, raw
  end
end
