require 'savon'
require 'wikipedia'
require 'htmlentities'
require 'builder'
require 'open-uri'
require 'tempfile'
require 'bio-isoelectric_point'
require 'bio'
require 'thread'
require 'csv'
require 'net/http'
require 'dalli'
require 'require_all'
require 'xml'
require 'parallel'
require 'active_support/all'
require 'httpclient'
require_relative 'synonym_cleaner'
require_all File.dirname(__FILE__) + '/data-wrangler/'

# -*- coding: utf-8 -*- 
 module DataWrangler
  def self.configure
    yield @configuration
  end
  
  def self.configuration
    @configuration
  end
  
  module Annotate
    # autoload the compound annotation and protein annotation module
    autoload :Compound, 'data-wrangler/annotate/compound'
    autoload :Protein, 'data-wrangler/annotate/protein'
  end

  protected

  @configuration = DataWrangler::Configuration.new
end
