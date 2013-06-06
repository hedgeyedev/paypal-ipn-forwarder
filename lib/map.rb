class Map

    MAP = {
          'gpmac_1231902686_biz@paypal.com' => 'developer_one',
          'paypal@gmail.com' => 'developmentmachine:9999/'
          }

  def computer(paypal_id)
    MAP[paypal_id]
  end

end