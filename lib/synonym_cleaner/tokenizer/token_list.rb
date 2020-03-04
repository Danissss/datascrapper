require 'synonym_cleaner/tokenizer'

module  SynonymCleaner
  class Tokenizer::TokenList
    include Enumerable

    attr_accessor :token_list

    def initialize(token_list,capitalization)
      @token_list = token_list.map do |token|
        RuleBook.token_from_string(token)
      end
      link_tokens
      mark_first_word if capitalization
    end

    def style_permutations
      styles = self.synonym_styles_list.clone
      if styles.empty?
        []
      elsif styles.length == 1
        styles.first.map{|s|[s]}
      else
        # Generate all the combinations of different styles
        styles.reduce(styles.shift){|p,i| p.product(i) }.map(&:flatten)
      end
    end

    def synonym_styles_list
      self.token_list.map{|l|l.synonym_styles.clone}.select(&:any?).uniq
    end

    def generate_synonyms
      ([self.to_s] + self.style_permutations.map{|s| self.to_s(style: s)}).uniq.sort
    end

    def each
      self.token_list.each do |token|
        yield token
      end
    end

    def to_s(options={})
      @token_list.map{|t| t.to_s(options) }.join
    end

    def to_html(options={})
      @token_list.map{|t| t.to_html(options) }.join
    end

    private

    def mark_first_word
      first_word = @token_list.find(&:can_be_first_word?)
      first_word.set_as_first_word unless first_word.nil?
    end

    def link_tokens
      length = @token_list.length
      length.times do |i|
        before_i = i-1
        after_i  = i+1
        token = @token_list[i]

        token.previous = @token_list[before_i] if before_i >= 0
        token.next     = @token_list[after_i]  if after_i  < length
      end
    end

  end
end
