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
require_all File.dirname(__FILE__) + '/data-scrapper/'

# -*- coding: utf-8 -*-
# how I run test for data-wrangler DataWrangler::Annotate::Compound.by_inchikey("BRMWTNUJHUMWMS-LURJTMIESA-N") 
 module DataScrapper
  module Annotate
    # autoload the compound annotation and protein annotation module
    autoload :Compound, 'data-scrapper/annotate/compound'
    autoload :Protein, 'data-scrapper/annotate/protein'
  end
end
