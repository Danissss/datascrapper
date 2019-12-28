require "set"

module SynonymCleaner
  autoload :Tokenizer, 'synonym_cleaner/tokenizer' 
  autoload :Token, 'synonym_cleaner/token'
  autoload :RuleBook, 'synonym_cleaner/rule_book'
  autoload :Exception, 'synonym_cleaner/exception'

  def self.tokenizer
    @tokenizer ||= Tokenizer.new
  end

  # Generates a list of synonyms given a name
  def self.generate_synonyms(name,options={})
    synonyms = tokenizer.tokenize(name,true).generate_synonyms
    unless options[:keep_original]
      name_pattern = Regexp.new Regexp.quote(name), "i"
      synonyms.delete(synonyms.grep(name_pattern).first)
    end
    return synonyms
  end

  # Capitalize the chemical name based on conventions
  # for chemical names
  def self.capitalize(name)
    # boolean value indicating capitalization (true)
    tokenizer.tokenize(name,true).to_s
  end

  def self.decapitalize(name)
    # boolean value indicating capitalization (false)
    tokenizer.tokenize(name,false).to_s
  end

  # Add italics for chemical names
  def self.htmlify(name)
    tokenizer.tokenize(name,true).to_html
  end

  # Given a list of synonyms fills in missing synonyms
  # by expanding them 
  def self.add_missing_synonyms(synonyms)
    synoynym_set = Hash.new
    synonyms.each{|w| synoynym_set[w.downcase] = w}

   new_synonyms = self.get_missing_synonyms_list(synonyms)
   (synonyms + new_synonyms).sort
  end

  # Given a list of synonyms return the synonyms missing from the list only
  def self.get_missing_synonyms_list(synonyms)
    original_synonym_set = synonyms.map(&:downcase).to_set

    new_synonyms = synonyms.map do |synonym|
      SynonymCleaner.generate_synonyms(synonym)
    end.flatten.uniq
    new_synonyms.select{|s| !original_synonym_set.include?(s.downcase) }
  end
end
