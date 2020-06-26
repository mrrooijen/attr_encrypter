# frozen_string_literal: true

module AttrEncrypter::Errors
  class NoKeychainError < StandardError
    def message
      "AttrEncrypter.new(keychain) requires a valid keychain containing at least one key." \
      "\nYou can generate a key using AttrEncrypter::Generator.generate_key(version = 1)." \
      "\nHere's a (version 1) key if you need one: #{AttrEncrypter::Generator.generate_key}" \
    end
  end
end
