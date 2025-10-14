# The workaround was found here: https://github.com/ruby/openssl/issues/949
require "openssl"

s = OpenSSL::X509::Store.new.tap(&:set_default_paths)

OpenSSL::SSL::SSLContext.send(:remove_const, :DEFAULT_CERT_STORE) rescue nil
OpenSSL::SSL::SSLContext.const_set(:DEFAULT_CERT_STORE, s.freeze)
