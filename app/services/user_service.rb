class UserService
  class << self
    def create_from_web(session)
      User.find_or_create_by(ext_id: session.id) do |user|
        user.ext_id = session.id
        user.source = :web
      end
    end

    def create_from_telegram(message)
      User.find_or_create_by(ext_id: message.from.id) do |user|
        user.ext_id = message.from.id
        user.first_name = message.from.first_name
        user.last_name = message.from.last_name
        user.username = message.from.username
        user.source = :telegram
      end
    end
  end
end
