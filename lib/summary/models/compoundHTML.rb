require 'sqlite3'

module ChemoSummarizer
  module Models
    class CompoundHTML		

      def initialize

      end


      def setup_table(compound)


        table ="<div style=\" width: 340px; border:5px solid grey;background-color:rgba(200,200,200,0.1) ;text-align:left;position:relative;margin-right:10em;margin-bottom:3em\">"
        table += "<table id=\"protIDs\" class=\"table\" style=\"width: 320px;\">"

        # Get image from classyfire page using inchikey, if it doesn't exist try search with smiles and take the
        # generated page file image
        # TODO: Add smiles search option

        inchikey = compound.structures.inchikey.to_s

        if inchikey[0..8] == 'InChIKey='
          inchikey = inchikey[9..-1]
        end
        #puts inchikey
        image_get = Nokogiri::HTML(open "http://classyfire.wishartlab.com/entities/#{inchikey}/")

        table += get_image(image_get.css('img')[0]['src'])
        table += get_structures(compound) if compound.structures.present?
        table += get_classification(compound.classifications[0]) if compound.classifications[0].present?
        table += get_properties(compound.properties) if compound.properties.present?	
        table += get_ids(compound) if compound.identifiers.present?
        table += "<br><br></table></div>"

        table
      end


      def to_html(data,compound)
				compound_exists = false
				data.each do |title,item|
					next if item.nil?
					next if item.text.nil? && item.nested.empty?
					next if title == "Introduction"
					compound_exists = true
				end

				if !compound_exists
					template = "<div><h1 style = \"word-break:break-all\">Compound not found</h1></div>"
				else
		      template = "<div class = \"container\"><div class = \"row\"><div class=\"col-md-12\">" 
					template +="<div class = \"col-md-6\"><h1 style = \"word-break:break-all\">#{compound.identifiers.name}</h1></div></br></br></br>"
					table = setup_table(compound)
		      template += "<div style = \"float:right; margin-left: 20px\">#{table}</div>" if table.present?
					template += "<div class =\"container\">"
				  data.each do |title,item|
				    next if item.nil?
				    next if item.text.nil? && item.nested.empty?
						#template += "<div style = \"float:left\">"
				    template += "<div class = \"col-md-6\"><h4 id=\"#{title}\"><b> #{title}</b></h4></div></br>" if title != "Introduction"
				  	template += "<p class=\"text-xs-left\"> #{item.text.strip.gsub("\n","<br/>")}</p>" if item.text.present?
				    template += "<br/>" if item.text.nil?
				    item.nested.each do |nest|
				      	template += "<h5 id=\"#{nest.name}\"><b>#{nest.name}</b></h4>" +
				            "<p class=\"protText\">#{nest.text.strip.gsub("\n","<br/>")}</p>" +
				            "<br/>"
						end
				   	template += create_table_contents(data) if title == "Introduction"
					
				    end
					template += "</div>"
				  template += "</div></div></div>"
				end
				return template
      end
			

      def create_table_contents(data)
        table = "<div style=\"width:280px;padding: 10px 0px ;border:5px solid grey;background-color:rgba(200,200,200,0.1) ;text-align:left;  \">"
        table += "<table><nav role= \"navigation\" class= \"table-of-contents\">"
        table += "<h4 style = \" padding-left: 5px;\">Contents</h4>"
        table+= "<ul style=\"list-style-type:none;\">"
        i = 1
        data.each do |title,item|
          next if title == "Introduction"
          next if item.nil?
					next if item.text.nil? && (item.nested.nil? || item.nested.empty?)
			
          table += "<li><a href=\"##{title}\"class=\"tablelinks\">#{i} #{title}</a></li>"
          k = 1
          table += "<ul style=\"list-style-type:none; padding-left: 30px;\">" if item.nested.any?
          item.nested.each do |nest|
              table += "<li><a href=\"##{nest.name}\"class = \"tablelinks\">#{i}.#{k} #{nest.name}</a></li>"
              k += 1
            end
          table += "</ul>" if item.nested.any?
          table += "</li>"
          i += 1
          end
        
        table += "</ul></nav></table></div></br></br>"
        return table
      end


      def get_image(image_url)
        if !image_url.nil?
          return "<img src=\"#{image_url.to_s}\" width=\"100%\"/>"
        end
      end


      def get_properties(properties)
        table = "<tr><th COLSPAN = 2 style =\"background-color: rgba(100,100,100,0.1); text-align:center; word-break:keep-all; white-space:nowrap;\">Basic Properties</th></tr>"
        id_hash = { 'Atomic Mass:' => get_value(properties.molecular_weight),
          'Melting Point' => properties.melting_point,
          'Boiling Point' => properties.boiling_point,
          'Density' => properties.density,
          'Water Solubility' => properties.solubility.to_s.gsub("e+00","") ,
          'Formal Charge' => (properties.formal_charge if properties.formal_charge.to_i != 0),
          'pKa' => get_value(properties.pKa),
          'logP' => get_value(properties.logP),
          'Polar Surface Area' => get_value(properties.polar_surface_area)}
        i = 0;
        id_hash.each do |header, id|
          if !id.nil? && id != ""
            i+= 1;
            table = table + "<tr><th>#{header}</th><th>#{id}</th></tr>"
          end
        end
        if (i < 5)
          id_hash = { 'Polarizability' => get_value(properties.polarizability),
            'Refractivity' => get_value(properties.refractivity),
          }
          id_hash.each do |header, id|
            if !id.nil?
              table = table + "<tr><th>#{header}</th><th>#{id.to_f.round(3).to_s}</th></tr>"
            end
          end
        end
        table
      end


			def get_value(value)
				if value.present?
					return value.to_f.round(2)
				else
					return nil
				end
			end
			

      def get_structures(compound)
        table = "<tr><th COLSPAN = 2 style =\"background-color: rgba(100,100,100,0.1); text-align:center; word-break:keep-all; white-space:nowrap;\">Identifiers</th></tr>"
        inchikey = ''
        if compound.structures.inchikey.present?
          if compound.structures.inchikey.include? "="
            inchikey = compound.structures.inchikey.split("=")[-1]
          else
            inchikey = compound.structures.inchikey
          end
        end
        id_hash = {'IUPAC' => (compound.identifiers.iupac_name if compound.identifiers.iupac_name.present?),
          'InChI Key' => (inchikey if inchikey.present?),
          'InChI' => (compound.structures.inchi if compound.structures.inchi.present?),
          'SMILES' => (compound.structures.smiles if compound.structures.smiles.present?)}
        id_hash.each do |header, id|
          if !id.nil?
            table += "<tr><th>#{header}</th><th style=\"word-break:break-all\">#{id}</th></tr>"
          end
        end
        table
      end


      def get_ids(compound)


        table = "<tr><th COLSPAN = 2 style =\"background-color: rgba(100,100,100,0.1); text-align:center; word-break:keep-all; white-space:nowrap;\">Database Accessions</th></tr>"

        if !compound.identifiers.pubchem_id.nil?
          pubchem_id = "<a target=\"_blank\" href=\"https://pubchem.ncbi.nlm.nih.gov/compound/" +
            "#{compound.identifiers.pubchem_id}\">#{compound.identifiers.pubchem_id}</a>"
        else
          pubchem_id = nil
        end

        if !compound.identifiers.moldb_id.nil?
          moldb_id = "<a target=\"_blank\" href=\"http://moldb.wishartlab.com/molecules/" +
            "#{compound.identifiers.moldb_id}\">#{compound.identifiers.moldb_id}</a>"
        else
          moldb_id = nil
        end
        if !compound.identifiers.drugbank_id.nil?
          drugbank_id = "<a target=\"_blank\" href=\"http://www.drugbank.ca/drugs/" +
            "#{compound.identifiers.drugbank_id}\">#{compound.identifiers.drugbank_id}</a>"
        else
          drugbank_id = nil
        end
        if !compound.identifiers.hmdb_id.nil?
          hmdb_id = "<a target=\"_blank\" href=\"http://www.hmdb.ca/metabolites/" +
            "#{compound.identifiers.hmdb_id}\">#{compound.identifiers.hmdb_id}</a>"
        else
          hmdb_id = nil
        end
        if !compound.identifiers.t3db_id.nil?
          t3db_id = "<a target=\"_blank\" href=\"http://www.t3db.ca/toxins/" +
            "#{compound.identifiers.t3db_id}\">#{compound.identifiers.t3db_id}</a>"
        else
          t3db_id = nil
        end
				if !compound.identifiers.foodb_id.nil?
          foodb_id = "<a target=\"_blank\" href=\"http://www.foodb.ca/compounds/" +
            "#{compound.identifiers.foodb_id}\">#{compound.identifiers.foodb_id}</a>"
        else
          foodb_id = nil
        end
				if !compound.identifiers.ecmdb_id.nil?
          ecmdb_id = "<a target=\"_blank\" href=\"http://www.ecmdb.ca/compounds/" +
            "#{compound.identifiers.ecmdb_id}\">#{compound.identifiers.ecmdb_id}</a>"
        else
          ecmdb_id = nil
        end
        if !compound.identifiers.chebi_id.nil?
          chebi_id = "<a target=\"_blank\" href=\"https://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:" +
            "#{compound.identifiers.chebi_id}\">#{compound.identifiers.chebi_id}</a>"
        else
          chebi_id = nil
        end

        if !compound.identifiers.kegg_id.nil?
          kegg_id = "<a target=\"_blank\" href=\"http://www.genome.jp/dbget-bin/www_bget?cpd:" +
            "#{compound.identifiers.kegg_id}\">#{compound.identifiers.kegg_id}</a>"
        else
          kegg_id = nil
        end
        if !compound.identifiers.chembl_id.nil?
          chembl_id = "<a target=\"_blank\" href=\"https://www.ebi.ac.uk/chembldb/index.php/compound/inspect/" +
            "#{compound.identifiers.chembl_id}\">#{compound.identifiers.chembl_id}</a>"
        else
          chembl_id = nil
        end

        id_hash = { 'PubChem:' => pubchem_id,
          'MolDB:' => moldb_id,
          'DrugBank' => drugbank_id,
          'HMDB' => hmdb_id,
          'T3DB' =>t3db_id,
					'FooDB' =>foodb_id,
					'ECMDB' => ecmdb_id,
          'KEGG:' => kegg_id,
          'ChEBI:' => chebi_id,
          'ChEMBL:' => chembl_id,
        }
        id_hash.each do |header, id|
          if !id.nil?
            table += "<tr><th>#{header}</th><th>#{id}</th></tr>"
          end
        end
        table
      end


      def get_classification(classification)
        table = "<tr><th COLSPAN = 2 style =\"background-color: rgba(100,100,100,0.1); text-align:center; word-break:keep-all; white-space:nowrap;\">Classification</th></tr>"
	
        id_hash = { 'Kingdom' => (classification.kingdom.name if classification.kingdom.present?),
          'Superclass' => (classification.superklass.name if classification.superklass.present?),
          'Class' => (classification.klass.name if classification.klass.present?),
          'Direct Parent' =>(classification.direct_parent.name if classification.direct_parent.present?),

        }
        id_hash.each do |header, id|
          if !id.nil?
            table += "<tr><th>#{header}</th><th>#{id}</th></tr>"
          end
        end
        table
      end

      def get_bioavailability(properties)
        table = ''
        id_hash = { 'Lipinski Rule' => properties.rule_of_five,
          'Veber Rule' => properties.veber,
          'Ghose Filter' => properties.ghose_filter,
          'MDDR-like' => properties.mddr,
          'Bioavailability' => properties.bioavailability,
        }
        id_hash.each do |header, id|
          if !id.nil?
            table = table + "<tr><th>#{header}</th><th>#{id}</th></tr>"
          end
        end
        table
      end

      def to_finish(result)
        template = "<!DOCTYPE html>
		  <html>
			<head>
				<meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\">
				<meta charset=\"UTF-8\"/>
				<meta name=\"description\" content=\"\">
				<meta name=\"author\" content=\"\">
				<title>ChemoSummarizer</title>

				<!-- Latest compiled and minified CSS -->
				<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css\">

				<!-- Optional theme -->
				<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css\">
				<style>
 				body {
				     padding-top: 10px;
				 }

				 p {
				     text-align: left;
				     margin: 2em 0;
				 }

				 .protText {
				     text-align: left;

				 }

				 .result {
				     padding: 4cm 1cm;
				     text-align: left;
				 }

				 #protIDs {
				     margin: 0 auto;
				     width: 340px;
				 }

				 .tablelinks{
					font-size: 12px;
			
				}
				button{
					width:75%
				}

				  img{border:none;display:block}/* add display:block to remove image underline*/
				  #outer{
				    width:100%;
				    margin:auto;
				  }
				  .wrap ul{
				    list-style:none;
				    padding:5px;

				  }
				  .wrap {
				    border:5px solid #ccc;
				    width: 100%;
				    overflow: auto;
				    padding-bottom:14px;
				    white-space:nowrap;
				  }
				  .wrap li {
				    text-align:center;
				    display:-moz-inline-box; /* gecko*/
				    display:inline-block;/* opera and safari*/
				    font-size: x-small;

				    padding:5px;

				  }
				  .wrap li a, .wrap li a span {
	          display: block;
	          margin: 0px 10px 0px 10px;
	          text-align: center;
	          font-size: x-small;
	          word-break: break-all;
	          width: 350px;
          }
				h4:after {
								
					 content:' ';
					 display:block;
					 border:2px solid #d0d0d0;
					 border-radius:4px;
					 -webkit-border-radius:4px;
					 -moz-border-radius:4px;
					 box-shadow:inset 0 1px 1px rgba(0, 0, 0, .05);
					 -webkit-box-shadow:inset 0 1px 1px rgba(0, 0, 0, .05);
					 -moz-box-shadow:inset 0 1px 1px rgba(0, 0, 0, .05);
				}

				h1:after {
					 content:' ';
					 display:block;
					 border:2px solid #d0d0d0;
					 border-radius:4px;
					 -webkit-border-radius:4px;
					 -moz-border-radius:4px;
					 box-shadow:inset 0 1px 1px rgba(0, 0, 0, .05);
					 -webkit-box-shadow:inset 0 1px 1px rgba(0, 0, 0, .05);
					 -moz-box-shadow:inset 0 1px 1px rgba(0, 0, 0, .05);
				}
				.table-of-contents{
					width:100%

				}
				</style>
			 </head>
			 <body>

				<nav class=\"navbar navbar-inverse navbar-fixed-top\">
				  <div class=\"container\">
				    <div class=\"navbar-header\">
				      <button type=\"button\" class=\"navbar-toggle collapsed\" data-toggle=\"collapse\" data-target=\"#navbar\" aria-expanded=\"false\" aria-controls=\"navbar\">
				        <span class=\"sr-only\">Toggle navigation</span>
				        <span class=\"icon-bar\"></span>
				        <span class=\"icon-bar\"></span>
				        <span class=\"icon-bar\"></span>
				      </button>
				      <a class=\"navbar-brand\" href=\"#\">ChemoSummarizer</a>
				    </div>
				    <div id=\"navbar\" class=\"collapse navbar-collapse\">
				    </div><!--/.nav-collapse -->
				  </div>
				</nav>

				<div class=\"container\">

				  <div class=\"result\">
				    #{result}
				  </div>

				</div><!-- /.container -->

				<!-- JQuery -->
				<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js\"></script>

				<!-- Latest compiled and minified JavaScript -->
				<script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js\"></script>
			 </body>
		  </html>"
        template
      end
    end
  end
end
