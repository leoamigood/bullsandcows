class UsersController < BaseApiController
  before_action :set_session_realm

  def me
    user = UserService.create_from_web(session);
    render json: { user: Responses::User.new(user) }
  end

end
