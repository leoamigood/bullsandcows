RSpec.configure do |config|

  def expect_ok
    expect(response).to be_success
    expect(response).to have_http_status(200)
  end

  def expect_not_found
    expect(response).not_to be_success
    expect(response).to have_http_status(404)
  end

  def expect_error
    expect(response).not_to be_success
    expect(response).to have_http_status(500)
  end

end
