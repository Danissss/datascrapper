module AlogpsGrabber
  def self.prediction_from_smiles(smiles)
    return nil if smiles.strip.blank?
    
    request = HTTPI::Request.new("http://www.vcclab.org/web/services/ALOGPS")
    request.body = 
    "<?xml version=\"1.0\" encoding=\"utf-8\" ?>
    <env:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
        xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
        xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\">
      <env:Body>
        <MOLECULES FORMAT='smi'><MOLECULE>#{smiles}</MOLECULE></MOLECULES>
      </env:Body>
    </env:Envelope>"
    
    request.headers = { "Accept-Charset" => "utf-8", 'Content-Type' => 'text/xml;charset=UTF-8', 'SOAPAction' => 'getAlogpsResults' }
    response = HTTPI.post request, :httpclient

    result = AlogpsResult.new
    result.process_xml_result(response.body)
    result
  end

  class AlogpsResult
    require 'rexml/document'
    
    attr_accessor :input_data, :smiles, :logp, :logp_error, 
                :logs, :logs_error, :solubility, :solubility_units
    
    def process_xml_result(xml)
      doc = REXML::Document.new(xml)
    
      doc.root.elements.each("soapenv:Body/RESULTS/BATCH/MOLECULE") do |molecule|
        next if molecule.elements.blank?
        
        @input_data = molecule.elements["INPUTDATA"].text
        @smiles = molecule.elements["SMILES"].text
        
        if molecule.elements["LOGP"]
          @logp = molecule.elements["LOGP"].text
          @logp_error = molecule.elements["LOGPERR"].text
        end
        
        if molecule.elements["LOGS"]
          @logs = molecule.elements["LOGS"].text
          @logs_error = molecule.elements["LOGSERR"].text
        end
        
        if molecule.elements["SOLUBILITY"]
          @solubility = molecule.elements["SOLUBILITY"].text
          @solubility_units = molecule.elements["SOLUBILITY"].attributes["UNITS"]     
        end
      end
    end
    
  end

end