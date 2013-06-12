SuckerPunch.config do
  queue name: :email_queue, worker: SendGrid, workers: 1
end