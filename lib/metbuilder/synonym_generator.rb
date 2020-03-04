require_relative 'chains'

class SynonymGenerator
	attr_accessor :head

	# TODO: generate a list of fatty acids with their synonyms

	def initialize(klass, subklass, abbrev, fa1, fa2, fa3, fa4, sys_name)
		@klass = klass
		@subklass = subklass
		@abbrev = abbrev
		@head = @abbrev.split("(")[0]
		@fa1 = fa1
		@fa2 = fa2
		@fa3 = fa3
		@fa4 = fa4
		@sys_name = sys_name

		# i.e. Cer(d18:0/20:0), this is what you'd get:
		# puts @klass #~> SP
		# puts @subklass #~> ceramide
		# puts @abbrev #~> Cer(d18:0/20:0)
		# puts @head #~> Cer
		# puts @fa1 #~> d18:0
		# puts @fa2 #~> 20:0
		# puts @fa3 #~> nil
		# puts @fa4 #~> nil
		# puts @sys_name #~> N-(eicosanoyl)-sphinganine

		# initialize the synonyms array
		@synonyms = Array.new
	end

	def generate_synonyms
		#general synonym for every class:
		# each lipid class will get 3 primary synonyms directly by doing the following:
		# we can directly append the subklass as a synonym for the full abbreviation
		@synonyms << @subklass.capitalize
		# we can also directly append the systematic name
		@synonyms << @sys_name
		# as well as appending this! it basically substitute the head in the abbreviation with the its name
		@synonyms << @subklass.capitalize + @abbrev.sub(@head, '')

		# for class specific synonyms:
		# booleans
		is_sphingolipid = false
		is_cardiolipin = false
		is_glycerophospholipid = false
		is_glycerolipid = false
		is_cholesterylEster = false
		is_acylGlycine = false
		is_acylCarnitine = false

		# get the klass
		if @klass == 'SP' #sphingolipid
			is_sphingolipid = true
		elsif @klass == 'CL' #cardiolipin
			is_cardiolipin = true
		elsif @klass == 'GPL' #glycerophospholipid
			is_glycerophospholipid = true
		elsif @klass == 'GL' #glycerolipid
			is_glycerolipid = true
		elsif @klass == 'CE' #cholesterylEster
			is_cholesterylEster = true
		elsif @klass == 'AG' #acylGlycine
			is_acylGlycine = true
		elsif @klass == 'AC' #acylCarnitine
			is_acylCarnitine = true
		end

		# break down side chains for easy iteration
		if !@fa1.nil?
			fa1 = @fa1.split(":")
			if is_sphingolipid
				@type = fa1[0][0]
				@fa1_1 = fa1[0][1..-1]
				@fa1_2 = fa1[1]
			else
				@fa1_1 = fa1[0]
				@fa1_2 = fa1[1]
			end
		end
		if !@fa2.nil?
			fa2 = @fa2.split(":")
			@fa2_1 = fa2[0]
			@fa2_2 = fa2[1]
		end
		if !@fa3.nil?
			fa3 = @fa3.split(":")
			@fa3_1 = fa3[0]
			@fa3_2 = fa3[1]
		end
		if !@fa4.nil?
			fa4 = @fa4.split(":")
			@fa4_1 = fa4[0]
			@fa4_2 = fa4[1]
		end

		# identify the class and jump to its method/function
		if is_sphingolipid
			sphingolipid_syn
		elsif is_glycerophospholipid
			glycerophospholipid_syn
		elsif is_cardiolipin
			cardiolipin_syn
		elsif is_glycerolipid
			glycerolipid_syn
		elsif is_acylCarnitine
			acylCarnitine_syn
		elsif is_acylGlycine
			acylGlycine_syn
		elsif is_cholesterylEster
			cholesterylEster_syn
		end

		# return the sorted array full of possible synonyms
		if !@synterms.nil?	
			return @synonyms.sort
		else
			return @synonyms
		end
	end

	def sphingolipid_syn
		if @sys_name.include?('-3-keto-')
			syn = @sys_name.gsub('-3-keto-', '-1-deoxy-')
			@synonyms << syn
			if @head.include?('Cer')
				if @type == 'd'
					syn = 'C' + @fa2_1.to_s + 'DH 1-deoxyCer'
				else
					syn = 'C' + @fa2_1.to_s + ' 1-deoxyCer'
				end
				@synonyms << syn
			end
		elsif @sys_name.include?('sphinganine')
			syn = @sys_name.gsub('sphinganine', 'dihydrosphingosine')
			@synonyms << syn
			syn = @sys_name.gsub('sphinganine', 'D-erythro-Sphinganine')
			@synonyms << syn
		elsif @sys_name.include?('dihydrosphingosine')
			syn = @sys_name.gsub('dihydrosphingosine', 'sphinganine')
			@synonyms << syn
		elsif @sys_name.include?('sphing-4-enine')
			syn = @sys_name.gsub('sphing-4-enine', 'sphingosine')
			@synonyms << syn
			syn = @sys_name.gsub('sphing-4-enine', 'D-erythro-Sphingosine')
			@synonyms << syn
			syn = @sys_name.gsub('sphing-4-enine', '4-Sphingenine')
			@synonyms << syn
			syn = @sys_name.gsub('sphing-4-enine', 'D-Sphingosine')
			@synonyms << syn
			syn = @sys_name.gsub('sphing-4-enine', 'sphingenine')
			@synonyms << syn
			syn = @sys_name.gsub('sphing-4-enine', 'erythro-4-sphingenine')
			@synonyms << syn
		elsif @sys_name.include?('4E,8E-sphingdienine')
			syn = @sys_name.gsub('4E,8E-sphingdienine', 'sphinga-4E,8E-diene')
			@synonyms << syn
			syn = @sys_name.gsub('4E,8E-sphingdienine', 'sphinga-4E,8E-dienine')
			@synonyms << syn
			syn = @sys_name.gsub('4E,8E-sphingdienine', '4,8-sphingenine')
			@synonyms << syn
			syn = @sys_name.gsub('4E,8E-sphingdienine', '(4E,8E)-4,8-sphingenine')
			@synonyms << syn
		end
	end


	def glycerophospholipid_syn
		detailed = false
		unsaturated_chain_parts = [@fa1_1, @fa2_1]
		saturated_chain_parts = [@fa1_2, @fa2_2]
		saturated_chain_parts.map! do |part|
			part =~ /\((.*\))/
			if !part.nil?
				detailed = true
			end
			part = part.gsub /\((.*\))/, ''
		end
		sum_of_unsaturated = unsaturated_chain_parts.inject(0){|sum, x| sum + x.to_i }
		sum_of_saturated = saturated_chain_parts.inject(0){|sum, x| sum + x.to_i }

		synterms = nil
		prefixes = nil
		if @head == "PC"
			synterms = ['Lecithin']
			prefixes = ['PC', 'GPCho', 'Phosphatidylcholine']
		elsif @head == "PE"
			synterms = []
			prefixes = ['PE', 'GPEtn', 'Phophatidylethanolamine']
		elsif @head == "PS"
			synterms = []
			prefixes = ['PS', 'PSer', 'Phosphatidylserine']
		elsif @head == "PG"
			synterms = []
			prefixes = ['PG', 'GPG', 'Phosphatidylglycerol']
		elsif @head == "PGP"
			synterms = ["3-sn-phosphatidyl-1'-sn-glycerol 3'-phosphoric acid"]
			prefixes = ['PGP']
		elsif @head == "PI"
			synterms = []
			prefixes = ['PI', 'PIno', 'Phosphatidylinositol']
		elsif @head == "PIP"
			synterms = []
    	prefixes = ['PIP', 'Phosphatidylinositol Phosphate']
    elsif @head == "PIP2"
			synterms = []
    	prefixes = ['PIP2', 'Phosphatidylinositol Diphosphate']
    elsif @head == "PIP3"
			synterms = []
    	prefixes = ['PIP3', 'Phosphatidylinositol Triphosphate']
    elsif @head == "PA"
    	synterms = []
    	prefixes = ['PA', 'Phosphatidic Acid']
    elsif @head == "CDP-DG"
    	synterms = []
    	prefixes = ['CDP-DG', 'CDP-Diacylglycerol']
    elsif @head == "Lyso-PC"
    	synterms = []
    	prefixes = ['LPC', 'LyPC', 'LysoPC', 'Lysophosphatidylcholine']
    elsif @head == "Lyso-PE"
    	synterms = ['Stearoyl phosphatidylethanolamine', 'Lysophosphatidylethanolamine']
    	prefixes = ['Lyso-PE', 'LysoPE', 'LPE', 'Lysophosphatidylethanolamine']
    elsif @head == "Lyso-PS"
    	synterms = []
    	prefixes = ['LPS', 'LyPS', 'LysoPS', 'Lysophosphatidylserine']
    elsif @head == "Lyso-PA"
    	synterms = []
    	prefixes = ['LPA', 'LyPA', 'LysoPA', 'Lysophosphatidic acid']
    elsif @head == "Lyso-PI"
    	synterms = []
    	prefixes = ['LPI', 'LyPI', 'LysoPI', 'Lysophosphatidylinositol']
    elsif @head == "PPA"
    	synterms = []
    	prefixes = []
    elsif @head == "PnC"
    	synterms = []
    	prefixes = []
    elsif @head == "PnE"
    	synterms = []
    	prefixes = []
    elsif @head == "PE-NMe"
    	synterms = []
    	prefixes = []
    elsif @head == "PE-NMe2"
    	synterms = []
    	prefixes = []
		else
			@synonyms = nil
		end

		if !@synonyms.nil?
			if !synterms.empty?
				synterms.each do |term|
					@synonyms << term
				end
			end
			if !prefixes.empty?
				prefixes.each do |pre|
					syn = pre + "(#{sum_of_unsaturated.to_s}:#{sum_of_saturated.to_s})"
					@synonyms << syn
				end

				if detailed
					prefixes.each do |pre|
						syn = pre + "(#{unsaturated_chain_parts[0]}:#{saturated_chain_parts[0]}/" +
						"#{unsaturated_chain_parts[1]}:#{saturated_chain_parts[1]})"
						@synonyms << syn
					end
				end
			end
		end
	end


	def cardiolipin_syn
		detailed = false
		prefixes = ["CL", "Cardiolipin"]
		suffix1 = "(1'-[#{@fa1}/#{@fa2}],3'-[#{@fa3}/#{@fa4}])"
		prefixes.each do |term|
			syn = term + suffix1
			@synonyms << syn
		end
		unsaturated_chain_parts = [@fa1_1, @fa2_1, @fa3_1, @fa4_1]
		saturated_chain_parts = [@fa1_2, @fa2_2, @fa3_2, @fa4_2]
		saturated_chain_parts.map! do |part|
			part =~ /\((.*\))/
			if !part.nil?
				detailed = true
			end
			part = part.gsub /\((.*\))/, ''
		end
		sum_of_unsaturated = unsaturated_chain_parts.inject(0){|sum, x| sum + x.to_i }
		sum_of_saturated = saturated_chain_parts.inject(0){|sum, x| sum + x.to_i }
		prefixes.each do |term|
			syn = term + "(#{sum_of_unsaturated.to_s}:#{sum_of_saturated.to_s})"
			@synonyms << syn
		end

		if detailed
			prefixes.each do |term|
				syn = term + "(#{unsaturated_chain_parts[0]}:#{saturated_chain_parts[0]}/" +
				"#{unsaturated_chain_parts[1]}:#{saturated_chain_parts[1]}/" +
				"#{unsaturated_chain_parts[2]}:#{saturated_chain_parts[2]}/" +
				"#{unsaturated_chain_parts[3]}:#{saturated_chain_parts[3]})"
				@synonyms << syn
			end
		end
	end


	def glycerolipid_syn
		detailed = false
		unsaturated_chain_parts = [@fa1_1, @fa2_1, @fa3_1]
		saturated_chain_parts = [@fa1_2, @fa2_2, @fa3_2]
		saturated_chain_parts.map! do |part|
			part =~ /\((.*\))/
			if !part.nil?
				detailed = true
			end
			part = part.gsub /\((.*\))/, ''
		end
		sum_of_unsaturated = unsaturated_chain_parts.inject(0){|sum, x| sum + x.to_i }
		sum_of_saturated = saturated_chain_parts.inject(0){|sum, x| sum + x.to_i }

		synterms = nil
		prefixes = nil
		if @head == "TG"
			synterms = ["Triglyceride", "Triacylglycerol"]
			prefixes = ["TG", "TAG", "Tracylglycerol"]
		elsif @head == "MG"
			synterms = ["1-monoacylglyceride", "1-monoacylglycerol"]
			prefixes = ["MG", "MAG"]
		elsif @head == "DG"
			synterms = ["Diacylglycerol", "Diglyceride"]
			prefixes = ["DG", "DAG", "Diacylglycerol"]
		else # here could go the 4th head (GL) but couldn't find information on it as of Jan 08/2018
			@synonyms = nil
		end

		if !@synonyms.nil?
			if !synterms.empty?
				synterms.each do |term|
					@synonyms << term
				end
			end
			prefixes.each do |pre|
				syn = pre + "(#{sum_of_unsaturated.to_s}:#{sum_of_saturated.to_s})"
				@synonyms << syn
			end

			if detailed
				prefixes.each do |pre|
					syn = pre + "(#{unsaturated_chain_parts[0]}:#{saturated_chain_parts[0]}/" +
					"#{unsaturated_chain_parts[1]}:#{saturated_chain_parts[1]}/" +
					"#{unsaturated_chain_parts[2]}:#{saturated_chain_parts[2]})"
					@synonyms << syn
				end
			end
		end
	end


	def acylCarnitine_syn
	end


	def acylGlycine_syn
	end


	def cholesterylEster_syn
		chain_name1 = $chains[@fa1][0]
		if chain_name1[0] == "(" and chain_name1[-1] == ")"
			chain_name1 = chain_name1[1..-2]
		end
		chain_name2 = chain_name1.sub("yl", "ic acid")
		@synonyms << chain_name2.capitalize
		@synonyms << "Cholesteryl 1-#{chain_name2}"
		chain_name3 = chain_name1.sub("yl", "ate")
		@synonyms << chain_name3.capitalize
		@synonyms << "Cholesteryl 1-#{chain_name3}"

		prefixes = ["CE", "Cholesterol ester", "Cholesteryl ester"]
		prefixes.each do |pre|
			@synonyms << "#{pre}(#{@fa1}/0:0)"
			@synonyms << "#{@fa1} #{pre}"
		end
		@synonyms << "1-#{chain_name1}-cholesterol"

		sysname = @sys_name
		@synonyms << sysname.sub('β', 'b')
		@synonyms << sysname.sub("ate", "ic acid")
		@synonyms << sysname.sub("ate", "ic acid").sub('β', 'b')
	end
end