class Send_Grid_Mail_Creator

  def create(mail)
    @mail = mail
    @email = Hash.new
    load_yml
    @email = @config.clone
    combine_params
    @email
  end

  def load_yml
    @config = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'config.yml'))
  end

  def combine_params
    @mail.each_key do |key|
      @email[key] = @mail[key]
    end
  end

end
