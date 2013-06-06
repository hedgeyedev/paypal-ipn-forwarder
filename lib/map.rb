class Map
  def initialize
    $map = {
          'gpmac_1231902686_biz@paypal.com' => 'developer_one',
          'paypal@gmail.com' => 'developmentmachine:9999/'
          }
  end

  def computer(paypal_id)
    $map[paypal_id]
  end

  def paypal_id(computer)
    $map[computer]
  end

end