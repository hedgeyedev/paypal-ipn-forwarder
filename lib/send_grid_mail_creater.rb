class Send_Grid_Mail_Creator

  def create(mail)
    email = Hash.new
    config = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'config.yml'))
    email = config.clone
    mail.each_key do |key|
      email[key] = mail[key]
    end
    email
  end

end
