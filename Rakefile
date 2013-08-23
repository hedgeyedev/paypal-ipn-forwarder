#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib/paypal_ipn_forwarder'
  t.test_files = FileList['spec/*_spec.rb']
  t.verbose = true
end

task :default => :spec