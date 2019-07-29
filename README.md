# MongoMapper::Plugins::Sluggable

NOTE: No longer maintained, as mongomapper is no longer maintained.

[![Build Status](https://travis-ci.org/leifcr/mm-sluggable.svg?branch=master)](https://travis-ci.org/leifcr/mm-sluggable) [![Coverage Status](https://coveralls.io/repos/leifcr/mm-sluggable/badge.png)](https://coveralls.io/r/leifcr/mm-sluggable) [![Dependency Status](https://gemnasium.com/leifcr/mm-sluggable.svg)](https://gemnasium.com/leifcr/mm-sluggable)

Add slugs to your fields. And use it for nice urls. Difference from other mm-sluggables: This uses regexp query for checking conflicting slugs, so you get only 2 queries even if your collection has 1000 upon 1000 of documents.

## Usage

Either load it into all models, or individual models:

Add to all models
```ruby
  #initializers/mongo.rb
  MongoMapper::Document.plugin(MongoMapper::Plugins::Sluggable)
```

Add to a specific model
```ruby
  #app/models/my_model.rb
  plugin MongoMapper::Plugins::Sluggable
```

Then call sluggable to configure it
```ruby
  sluggable :title, :scope => :account_id
```

NOTE: The slugs will always be updated if you change the field it creates
the slugs from. see options to change behaviour

Free slugs will be reused
Example: you have my-title-1 and my-title-3 creating a new slug will generate my-title-2

  Why always change slugs? Feels better to have same slug as title...

## Improve performance on your models

This is important to get fast queries! (you will regret if you don't add it...)

Read up on indexes here:
https://github.com/jnunemaker/mongomapper/issues/337

Easiest is to add db/indexes.rb to your app, then add this to that file:
  # db/indexes.rb
  MyModel.ensure_index(:slug_key)

## Options

Available options:

* :scope - scope to a specific field (default - nil)
* :key - what the slug key is called (default - :slug) - NOTE, don't change this one
* :method - what method to call on the field to sluggify it (default - :parameterize)
* :callback - when to trigger the slugging (default - :before_validation)
* :always_update - Always update the slug on update/save/create etc.
* :start - Which value the slugs should start with (default: 1)
* :max_length - The maxiumum length of the slug (default: 256)
* :disallowed\_bare\_slugs - Array of words that shouldn't be allowed as bare slugs. (default: ["new", "edit", "update", "create", "destroy"])

Eg.

```ruby
  sluggable :title, scope: :account_id, key: :title_slug, method: :to_url, always_update: true, disallowed_bare_slugs: ["dragon", "unicorn", "dog"]
```

This will slug the title to the title_slug key, scoped to the account, will use String#to_url to slug it and won't add an index to the key

## Versioning

If an item with the same slug exists, it will add a version number to the slug.

IE assuming we already have an item with the slug of "monkey", the slug will be generated as "monkey-1"

## Note on Patches/Pull Requests
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it.

## Install
Bundler: (You are most likely using bundler in your app...)
  gem 'mm-sluggable', :git => 'http://github.com/luuf/mm-sluggable.git'

## Thanks
* Richard Livsey for creating the original mm-sluggable
* John Nunemaker, Brandon Keepers & Others for MongoMapper

## Copyright
See LICENSE for details.
