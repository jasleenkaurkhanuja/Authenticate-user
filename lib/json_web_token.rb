class JsonWebToken 

    SECRET_KEY = Rails.application.secret_key_base
## encode -> id, secret_key, expiry
    def self.encode(payload, exp = 24.hours.from_now)
        payload[:exp] = exp.to_i 
        JWT.encode(payload, SECRET_KEY)
    end

## decode -> token
## to call -> token, secret_key, true, algorithm
    def self.decode(token)
        return nil unless token.present? 
        begin 
            decode = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')[0]
        end
    end
end