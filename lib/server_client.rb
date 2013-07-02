class ServerClient

  def initialize(mode)
    @test_mode = mode
  end

  def computer_testing(params)
    @params = params
    #params is ({'my_id'=>@my_id, 'test_mode'=>'on','@email'=>'bob@example.com'})
  end

  def store_ipn_response(paypal_id)

  end
end