# frozen_string_literal: true

class AttrEncrypter::Boxes

  KEY_FORMAT = /^(\d+)\.([a-f0-9]{64})$/.freeze

  def initialize(keychain)
    @boxes = keychain.split.reduce({}) do |keys, item|
      segments = item.match(KEY_FORMAT)
      version  = segments[1].to_i
      key      = [segments[2]].pack("H*")

      keys.merge(version => RbNaCl::SimpleBox.from_secret_key(key))
    end

    if @boxes.empty?
      raise AttrEncrypter::Errors::NoKeychainError
    end

    @boxes.freeze
  end

  def [](version)
    @boxes[version]
  end

  def latest_version
    @boxes.keys.max
  end
end
