class UsersController < BaseApiController
  before_action :set_session_realm
  before_filter :set_response_html_format

  def me
    render json: { user: Responses::User.new(realm) }
  end

  def console
    render inline: '<% console %>'
  end

end
