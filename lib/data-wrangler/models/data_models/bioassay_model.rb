# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class BioAssayModel < DataModel
		SOURCE = "BioAssay"
		  attr_accessor :description, :chembl_id, :url, :organism, :assay_type,
									  :reference, :count, :target_name, :bioactivity_type,
										:confidence
				

      def initialize(_name = nil, _chembl_id = nil, _url = nil)
        super(_name, SOURCE)
        @chembl_id = _chembl_id
        @url = _url
      end
		
		end
	end
end
