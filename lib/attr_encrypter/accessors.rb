# frozen_string_literal: true

module AttrEncrypter::Accessors

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def attr_encrypter(keychain, *attributes)
      attr_encrypter = AttrEncrypter.new(keychain)

      attributes.each do |attribute|
        reader         = "#{attribute}"
        writer         = "#{attribute}="
        digest_reader  = "#{attribute}_digest"
        digest_writer  = "#{attribute}_digest="

        define_method reader do
          digest = send(digest_reader)

          if digest.is_a?(String)
            attr_encrypter.decrypt(digest)
          end
        end

        define_method writer do |raw|
          if raw.is_a?(String)
            send(digest_writer, attr_encrypter.encrypt(raw))
          else
            send(digest_writer, nil)
          end
        end
      end
    end
  end
end
