# -*- coding: utf-8 -*- 
 module DataWrangler
  module PhysProp
  
    def self.find_by_cas(cas)
      data = open("http://esc.syrres.com/interkow/webprop.exe?CAS=#{cas}")
    end
  end
end