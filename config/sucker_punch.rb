SuckerPunch.config do
  queue name: :email_queue, worker: SendGrid, workers: 1
  queue name: :ipn_queue, worker: nil, workers: 0
end