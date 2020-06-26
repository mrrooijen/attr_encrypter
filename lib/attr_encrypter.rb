# frozen_string_literal: true

require "base64"
require "rbnacl"

class AttrEncrypter

  require "attr_encrypter/accessors"
  require "attr_encrypter/boxes"
  require "attr_encrypter/errors"
  require "attr_encrypter/generator"
  require "attr_encrypter/version"

  DIGEST_FORMAT = /^(\d+)\.([a-zA-Z0-9\+\=\n\/]+)$/.freeze

  def initialize(keychain)
    @boxes = Boxes.new(keychain || "")
  end

  def encrypt(raw)
    version   = @boxes.latest_version
    encrypted = @boxes[version].encrypt(raw)
    encoded   = Base64.encode64(encrypted)

    "#{version}.#{encoded}"
  end

  def decrypt(digest)
    segments  = digest.match(DIGEST_FORMAT)
    version   = segments[1].to_i
    encoded   = segments[2]
    encrypted = Base64.decode64(encoded)

    @boxes[version].decrypt(encrypted)
  end
end
