# DataWrangler

TODO: Write a gem description

## Installation

Add these lines to your application's Gemfile:

    gem 'data-wrangler',   git: 'git@bitbucket.org:wishartlab/datawrangler.git'
    gem 'wishart',         git: 'git@bitbucket.org:wishartlab/wishart'
    gem 'synonym_cleaner', git: 'git@bitbucket.org:wishartlab/synonym-cleaner.git'
    gem 'cite_this', git: "git@bitbucket.org:wishartlab/cite_this.git"
    gem 'chemoSummarizer', git: "git@bitbucket.org:wishartlab/chemoSummarizer.git"
    gem 'metbuilder',git: "git@bitbucket.org:wishartlab/metbuilder.git"
    gem 'similarity-NS', git: "git@bitbucket.org:wishartlab/similarity-ns.git"
    

And then execute:

    $ bundle install

Alternatively you can install it yourself as:

    $ git clone git@bitbucket.org:wishartlab/datawrangler.git
    $ cd datawrangler
    $ gem build data-wrangler.gem
    $ gem install data-wrangler

## Logic Map
`lib/data-wrangler/tools/jchem.rb` require `lib/data-wrangler/configuration.rb`
`lib/data-wrangler/configuration.rb` needs `lib/config/jchem.yml`
DataWrangler::JChem::Convert is required by:
```
lib/data-wrangler/annotate/compound.rb
lib/data-wrangler/models/compound.rb
lib/data-wrangler/models/compound_models/chembl_compound.rb
lib/data-wrangler/models/compound_models/classyfire_compound.rb
lib/data-wrangler/models/compound_models/kegg_compound.rb
lib/data-wrangler/models/compound_models/molconvert_compound.rb
lib/data-wrangler/models/compound_models/moldb_compound.rb
```
It sends API request to `http://jchem:test@jchem.wishartlab.com/jchem/rest-v0` with auth;
And get back result as JSON format.


