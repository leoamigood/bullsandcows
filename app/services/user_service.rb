class UserService
  class << self
    def create_from_web(session)
      User.find_or_create_by(ext_id: session.id) do |user|
        user.ext_id = session.id
        user.source = :web
      end
    end

    def create_from_telegram(message)
      user = User.find_or_create_by(ext_id: message.from.id) do |u|
        u.source = :telegram
      end

      user.first_name = message.from.first_name
      user.last_name = message.from.last_name
      user.username = message.from.username
      user.language = message.from.language_code
      user.save!

      user
    end
  end
end
