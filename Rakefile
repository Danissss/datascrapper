#!/usr/bin/env rake
require 'bundler/setup'
Bundler.setup(:default, :development)
require "bundler/gem_tasks"
require 'rake/extensiontask' # for build c extension
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
Rake::ExtensionTask.new('scrapper')


task :default => :spec
