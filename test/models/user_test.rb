require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def test_register
    data = { email: 'snvl1993@gmail.com', password: 'q1w2e3r4t5y6' }
    post user_registration_path, data
  end
end
