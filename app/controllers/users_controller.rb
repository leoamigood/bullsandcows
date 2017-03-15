class UsersController < BaseApiController
  before_action :set_session_realm

  def me
    render json: { user: Responses::User.new(realm) }
  end

end
