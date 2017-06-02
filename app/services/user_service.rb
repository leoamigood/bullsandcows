class UserService
  class << self
    def create_from_web(session)
      User.find_or_create_by(ext_id: session.id) do |user|
        user.ext_id = session.id
        user.source = :web
      end
    end

    def create_from_telegram(from)
      user = User.find_or_create_by(ext_id: from.id) do |u|
        u.source = :telegram
      end

      user.first_name = from.first_name
      user.last_name = from.last_name
      user.username = from.username
      user.language = from.language_code
      user.save!

      user
    end
  end
end
