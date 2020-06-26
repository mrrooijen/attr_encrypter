# AttrEncrypter

[![Gem Version](https://badge.fury.io/rb/attr_encrypter.svg)](https://badge.fury.io/rb/attr_encrypter)
[![Test Status](https://github.com/mrrooijen/attr_encrypter/workflows/Test/badge.svg)](https://github.com/mrrooijen/attr_encrypter/actions)

Encrypts/Decrypts, with key rotation, attributes on classes, using [RbNaCl] ([libsodium]).

This library was developed for- and extracted from [HireFire].

The documentation can be found on [RubyDoc].


### Compatibility

- Ruby 2.5+
- RbNaCl 7.0+


### Installation

Ensure that you've installed [libsodium], then add the gem to your Gemfile and run `bundle`.

```ruby
gem "attr_encrypter", "~> 1"
```


### Example

```rb
class Account
  include AttrEncrypter::Accessors

  # Defines the token accessor that seamlessly encrypts and decrypts
  # data stored in @token_digest.
  #
  # Note: This won't define a @token instance variable, as state is
  #       managed by the token_digest accessor using @token_digest.
  #
  # Note: You can add multiple attributes in a single attr_encrypter call.
  #       e.g. `attr_encrypter ENV["KEYCHAIN"], :attr_a, :attr_b, :attr_c`
  #
  attr_encrypter ENV["KEYCHAIN"], :token

  # Defines the token_digest accessor for storing and retrieving encrypted data.
  # You don't directly use this accessor. Both read and write operations should
  # always go through the token/token= methods provided by the attr_encrypter method.
  #
  # Consider making this accessor private. We'll leave it public for this demo.
  #
  attr_accessor :token_digest
end
```

The `KEYCHAIN` environment variable must contain one or more keys. To generate a key, use the following function.

```rb
AttrEncrypter::Generator.generate_key
```

Place the generated key in the `KEYCHAIN` environment variable.

The key consists of two segments, `<version>.<secret>`. The initial key has a version of 1. Versions determine which secrets will be used to encrypt and decrypt data.

With the key in place you'll be able to store and retrieve data using the dynamically defined `token` accessor. Data assigned with `token=` will automatically be encrypted and stored with `token_digest=` in `@token_digest`.

```rb
account                 = Account.new
account.token           = "my_secret_token"
account.token_digest # => "1.yCZGH0QEk8+OPT0ad29wVmCkvr/7NXZjZtxu23v2j9HKfehndH0qv9MsF4ME\n"
account.token        # => "my_secret_token"

account.instance_variable_get("@token")        # => nil
account.instance_variable_get("@token_digest") # => "1.yCZGH0QEk8+OPT0ad29wVmCkvr/7NXZjZtxu23v2j9HKfehndH0qv9MsF4ME\n"
```

The `@token_digest` value, like the keychain, also consists of two segments, `<version>.<data>`. The version matches the key version used to encrypt the data. This way, whenever data is accessed via `token`, it knows which secret to use to decrypt the data.

To clear the token, simply assign `nil` to it.

```rb
account.token           = nil
account.token_digest # => nil
```


### Active Record

This is a general purpose library, and while its only hard dependency is rbnacl (libsodium), it was designed to work seamlessly with Active Record.

```rb
class User < ActiveRecord::Base
  include AttrEncrypter::Accessors
  attr_encrypter ENV["KEYCHAIN"], :token
end
```

This assumes that you have a users table in the database, containing a column named `token_digest` of type text.


### Key Rotation

You'll want to rotate your keys at some point.

First, add a second key to the keychain (`ENV["KEYCHAIN"]` in this case).

To generate version 2 you can again use the following function, but this time using the version argument.

```rb
AttrEncrypter::Generator.generate_key 2 # or 3, 4, 5...
```

The keychain format allows any kind of whitespace to delimit keys.

```rb
ENV["KEYCHAIN"] = "<version>.<secret> <version>.<secret> <version>.<secret>"
```

For example.

```rb
ENV["KEYCHAIN"] = <<-EOS
  1.c1dbb0dd094d4f40916c9cc0d8c974151949f105c499366b2acd9da76de7e5e9
  2.3054563b2d80ae13c6e115405d6263e70be004f81eb3982f4a61ff9e9821e7d4
EOS
```

Then simply reassign the token to re-encrypt the token with key version 2.

```rb
User.find_each do |user|
  user.token = user.token
  user.save
end
```

The `user.token` (reader) decrypts the existing encrypted token from `token_digest` back to its unencrypted form using key version 1. It then uses the highest key version in the keychain, version 2, to re-encrypt the token with `user.token=` which overwrites the key version 1-encrypted token in `token_digest` with the key version 2-encrypted token. We then persist the key version 2-encrypted token to the database.


#### Quick Facts

* The order of the keys in the keychain is irrelevant.
* The key with the highest version in the keychain is always used for encryption.
* The key version used to encrypt data is stored along with the encrypted data (`<version>.<secret>`).
* The version of the encrypted data determines which key's secret to use in order to decrypt data.
* Keys can be safely removed from the keychain when none of the encrypted data requires it for decryption.
* It's recommended that you increment key versions by 1 when generating a new key.


### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mrrooijen/attr_encrypter.

First, install [libsodium] on your machine, and then install the remaining development dependencies:

```
$ bundle
```

To open an interactive console:

```
$ bundle console
```

To run the tests:

```
$ bundle exec rake
```

To view the code coverage (generated after each test run):

```
$ open coverage/index.html
```

To run the local documentation server:

```
$ bundle exec rake doc
```

To build a gem:

```
$ bundle exec rake build
```

To build and install a gem on your local machine:

```
$ bundle exec rake install
```

For a list of available tasks:

```
$ bundle exec rake --tasks
```


### Author / License

Released under the [MIT License] by [Michael van Rooijen].

[Michael van Rooijen]: https://michael.vanrooijen.io
[HireFire]: https://www.hirefire.io
[RubyDoc]: https://rubydoc.info/gems/attr_encrypter
[MIT License]: https://github.com/mrrooijen/attr_encrypter/blob/master/LICENSE.txt
[RbNaCl]: https://github.com/RubyCrypto/rbnacl
[libsodium]: https://doc.libsodium.org/
