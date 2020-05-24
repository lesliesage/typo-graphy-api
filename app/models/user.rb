class User < ApplicationRecord
    has_many :tests
    has_many :bookmarks
    # has_many :snippets, foreign_key 'creator_id'
    has_many :snippets, through: :bookmarks
    validates :username, uniqueness: { case_sensitive: false }
    validates :email, uniqueness: { case_sensitive: false }
    has_secure_password

    def generate_password_token!
        self.reset_password_token = generate_token
        self.reset_password_sent_at = Time.now.utc
        save!
    end

    def password_token_valid?
        (self.reset_password_sent_at + 4.hours) > Time.now.utc
    end

    def reset_password!(password)
        self.reset_password_token = nil
        self.password = password
        save!
    end

    private

    def generate_token
        SecureRandom.hex(10)
    end
end
