# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../lib/paypal_ipn_forwarder/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'paypal-ipn-forwarder'
  spec.version       = PaypalIpnForwarder::VERSION
  spec.authors       = ['Hedgeye CT Developers']
  spec.email         = %w{ct-developers@hedgeye.com}
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files = %w{.gitignore .ruby-gemset .ruby-version Gemfile Gemfile.lock README.md config.ru config_test.yml
                doc/seq_diagrams/README.md doc/seq_diagrams/all_sequence_diagram_source.seq doc/seq_diagrams/blocked.seq
                doc/seq_diagrams/blocked.svg doc/seq_diagrams/multiple.seq doc/seq_diagrams/multiple.svg
                doc/seq_diagrams/router.seq doc/seq_diagrams/router.svg doc/seq_diagrams/router_developer.seq
                doc/seq_diagrams/router_developer.svg doc/seq_diagrams/router_server.seq doc/seq_diagrams/router_server.svg
                doc/seq_diagrams/simple.seq doc/seq_diagrams/simple.svg lib/ipn_generator.rb lib/load_config.rb
                lib/mail_creator.rb lib/mail_sender.rb lib/poller.rb lib/router.rb lib/router_client.rb lib/server.rb
                lib/server_client.rb lib/server_ipn_reception_checker.rb lib/server_poll_checker.rb spec/configuration_spec.rb
                spec/ipn_generator_spec.rb spec/load_config_spec.rb spec/mail_creator_spec.rb spec/mail_sender_spec.rb
                spec/poller_spec.rb spec/router_client_spec.rb spec/router_spec.rb spec/server_client_spec.rb
                spec/server_ipn_reception_checker_spec.rb spec/server_poll_checker_spec.rb spec/server_spec.rb
                spec/spec_helper.rb start_paypal stop_paypal}
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w{lib}

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
