# -*- coding: utf-8 -*- 
 module DataWrangler

  def self.root
    File.expand_path('../..',__FILE__)
  end

  raw_config = File.read("#{self.root}/config/jchem.yml")
  JCHEM_CONFIG = YAML.load(raw_config)['development'].symbolize_keys

  # Load the Molecule JChem config file
  raw_config = File.read("#{self.root}/config/structure.yml")
  STRUCTURE_CONFIG = YAML.load(raw_config).symbolize_keys

  # Load YAML file into variables for quick access
  STRUCTURE_INCHIKEY    = STRUCTURE_CONFIG[:inchikey]
  STRUCTURE_STANDARDIZE = STRUCTURE_CONFIG[:standardized]
  STRUCTURE_FORMATS     = STRUCTURE_CONFIG[:formats].symbolize_keys
  STRUCTURE_PROPERTIES  = STRUCTURE_CONFIG[:properties].symbolize_keys
  STRUCTURE_IMAGES      = STRUCTURE_CONFIG[:images].symbolize_keys

  class Configuration
    attr_accessor :dalli_client, :cache_dir, :chemspider_token, 
                  :verbose, :auto_save_compounds, :jchem_path, 
                  :jchem_url, :thread_pool, :standardizer_config

    def initialize
      @dalli_client = nil
      @cache_dir = nil
      @chemspider_token = '6433f9db-f330-4601-a323-69e628b9fb35'
      @verbose = false
      @auto_save_compounds = false
      @jchem_path = '/Applications/ChemAxon/JChem/bin'
      @jchem_url = 'http://jchem:QLhg2i6y@jchem.wishartlab.com/jchem/rest-v0'

    end

    def auto_save_compounds
      @auto_save_compounds && @cache_dir
    end
    
    def dalli_client=(dc)
      raise ArgumentError, "Not a Dalli::Client" if dc.nil? || dc.class != Dalli::Client
      @dalli_client = dc
    end

    def cache_dir=(dir)
      raise ArgumentError, "Not a Directory" if dir.nil? || !File.directory?(dir)
      @cache_dir = dir
    end
    
    def disable_cache
      @cache_dir = nil
    end

    def memcache?
      !@dalli_client.nil?
    end

    def filecache?
      !@cache_dir.nil?
    end

    def standardizer_config
      return @standardizer_config if @standardizer_config.present?
      path = File.expand_path("../../config/standardizer.xml", __FILE__)
      File.open(path) do |f|
        @standardizer_config = f.read
      end
    end
  end
end