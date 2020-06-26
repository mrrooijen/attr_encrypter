# frozen_string_literal: true

module AttrEncrypter::Generator

  def self.generate_key(version = 1)
    byte_size    = RbNaCl::SecretBox.key_bytes
    secret_bytes = RbNaCl::Random.random_bytes(byte_size)
    secret_hex   = secret_bytes.unpack("H*")[0]

    "#{version}.#{secret_hex}"
  end
end
