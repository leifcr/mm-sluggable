require 'mongo_mapper'

module MongoMapper
  module Plugins
    module Sluggable
      extend ActiveSupport::Concern

      module ClassMethods
        def sluggable(to_slug = :title, options = {})
          class_attribute :slug_options

          self.slug_options = {
            :to_slug      => to_slug,
            :key          => :slug,
            :index        => true,
            :method       => :parameterize,
            :scope        => nil,
            :max_length   => 256,
            :always_update => true, # allow always updating slug...
          }.merge(options)
          # index => is deprecated added ensure index instead
          key slug_options[:key], String#, :index => slug_options[:index]
          self.ensure_index(slug_options[:key])

          before_validation :set_slug
        end
      end

      module InstanceMethods
        def set_slug
          options = self.class.slug_options
          
          if options[:always_update] == false
            return unless self.send(options[:key]).blank? 
          end

          to_slug = self[options[:to_slug]]
          return if to_slug.blank?

          the_slug = raw_slug = to_slug.send(options[:method]).to_s[0...options[:max_length]]

          conds = {}
          conds[options[:key]]   = the_slug
          conds[options[:scope]] = self.send(options[:scope]) if options[:scope]

          # todo - remove the loop and use regex instead so we can do it in one query
          i = 0
          while self.class.first(conds)
            i += 1
            conds[options[:key]] = the_slug = "#{raw_slug}-#{i}"
          end

          self.send(:"#{options[:key]}=", the_slug)
        end
      end
    end
  end
end