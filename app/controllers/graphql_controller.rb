class GraphqlController < ApplicationController
  include ActionView::Helpers::UrlHelper
  skip_before_action :verify_authenticity_token

  def create
    result = GraphqlSchema.execute(
        params[:query],
        variables: params[:variables],
        context: { }
    )
    render json: result
  end
end
