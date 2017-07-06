module WechatPay
  module Signature
    def self.api_key
      WechatPay::Config.sandbox ? WechatPay::Config.sandbox_key : WechatPay::Config.key
    end

    def self.sign(hash, key = self.api_key)
      str = hash.sort.map{|m| m.join("=")}.join("&")
      str += "&key=#{key}"
      Digest::MD5.hexdigest(str).upcase
    end

    def self.check_sign(hash)
      hash = hash['xml'] || hash[:xml] || hash
      return if (hash[:return_code] || hash['return_code']) == 'FAIL'
      signature = hash[:sign] || hash['sign']
      hash.delete(:sign)
      hash.delete('sign')
      raise WechatPay::Error.new "Signature does not match! The signature from wechat is #{signature} the one you got is #{sign(hash)}" unless signature.upcase == sign(hash).upcase
    end

    def self.get_sandbox_key_from_api
      return unless WechatPay::Config.sandbox

      response = WechatPay::API.sandbox_api_key.send
      response.sandbox_signkey
    end
  end
end
