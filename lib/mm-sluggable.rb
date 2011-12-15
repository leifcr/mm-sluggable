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

          # ensure_index have to be in an initializer. 
          # breaks the option to have indexes in a plugin
          # self.ensure_index(slug_options[:key])

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

          # this should be modified to use options instead
          # no need to set, so return
          return if (self.slug == the_slug)
          # puts self.slug.inspect
          # puts the_slug.inspect

          # conds = {}
          # conds[options[:key]]   = the_slug
          # conds[options[:scope]] = self.send(options[:scope]) if options[:scope]

          # first see if there is a equal slug
          used_slugs = self.class.where(options[:key] => "#{the_slug}")
          if (used_slugs.count > 0)
            last_digit = 0 # zero for last one...
            # if we are updating, check if the current slug is same as the one we want
            used_slugs = self.class.where(options[:key] => /(#{the_slug}-\d+)/).sort(options[:key].asc)
            new_slug_set = false
            used_slugs.each do |used_slug|
              # get the last digit through regex
              next_digit = used_slug.slug[/(\d+)$/]
              if (!next_digit.nil?)
                # catch any numbers that are in between and free
                if ((next_digit.to_i - last_digit.to_i) > 1)
                  the_slug = "#{raw_slug}-#{last_digit+1}"
                  new_slug_set = true
                  break # set a new slug, so all is good
                end
                last_digit = next_digit.to_i
                # puts last_digit.inspect
              end
            end
            the_slug = "#{raw_slug}-#{last_digit+1}" if new_slug_set == false
          end

          self.send(:"#{options[:key]}=", the_slug)
        end
      end
    end
  end
end