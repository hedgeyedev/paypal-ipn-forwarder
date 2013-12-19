# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../lib/paypal-ipn-forwarder/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name             = 'paypal-ipn-forwarder'
  spec.version          = PaypalIpnForwarder::VERSION
  spec.authors          = ['Hedgeye CT Developers']
  spec.email            = %w{ct-developers@hedgeye.com}
  spec.description      = %q{Write a gem description}
  spec.summary          = %q{Write a gem summary}
  spec.extra_rdoc_files = %w{README.md LICENSE.txt}
  spec.homepage         = ''
  spec.license          = 'MIT'

  spec.files         = %w{.gitignore .ruby-gemset .ruby-version Gemfile Gemfile.lock README.md config.ru config_test.yml
                doc/seq_diagrams/README.md doc/seq_diagrams/all_sequence_diagram_source.seq doc/seq_diagrams/blocked.seq
                doc/seq_diagrams/blocked.svg doc/seq_diagrams/multiple.seq doc/seq_diagrams/multiple.svg
                doc/seq_diagrams/router.seq doc/seq_diagrams/router.svg doc/seq_diagrams/router_developer.seq
                doc/seq_diagrams/router_developer.svg doc/seq_diagrams/router_server.seq doc/seq_diagrams/router_server.svg
                doc/seq_diagrams/simple.seq doc/seq_diagrams/simple.svg lib/paypal-ipn-forwarder/ipn_generator.rb
                lib/paypal-ipn-forwarder/load_config.rb lib/paypal-ipn-forwarder/mail_creator.rb
                lib/paypal-ipn-forwarder/mail_sender.rb lib/paypal-ipn-forwarder/poller.rb
                lib/paypal-ipn-forwarder/router.rb lib/paypal-ipn-forwarder/router_client.rb lib/paypal-ipn-forwarder/server.rb
                lib/paypal-ipn-forwarder/server_client.rb lib/paypal-ipn-forwarder/server_ipn_reception_checker.rb
                lib/paypal-ipn-forwarder/server_poll_checker.rb spec/configuration_spec.rb
                spec/ipn_generator_spec.rb spec/load_config_spec.rb spec/mail_creator_spec.rb spec/mail_sender_spec.rb
                spec/poller_spec.rb spec/router_client_spec.rb spec/router_spec.rb spec/server_client_spec.rb
                spec/server_ipn_reception_checker_spec.rb spec/server_poll_checker_spec.rb spec/server_spec.rb
                spec/spec_helper.rb start_paypal stop_paypal}
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w{lib}

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.1.0'
  spec.add_development_dependency 'rspec', '~> 2.13.0'
  spec.add_development_dependency 'awesome_print', '~> 1.1.0'
  spec.add_development_dependency 'timecop'
  #spec.add_development_dependency 'ruby-debug-base'
  spec.add_dependency 'sinatra', '~> 1.4.2'
  spec.add_dependency 'rack', '~> 1.5.2'
  spec.add_dependency 'rack-protection', '~> 1.5.0'
  spec.add_dependency 'pony', '~> 1.4.1'
  spec.add_dependency 'rest-client', '~> 1.6.7'

  # For source code debugging in RubyMine
  spec.add_dependency 'linecache19', '>= 0.5.12'
  spec.add_dependency 'ruby-debug-base19x', '>= 0.11.30.pre10'
  spec.add_dependency 'ruby-debug-ide', '>= 0.4.17.beta14'
end
