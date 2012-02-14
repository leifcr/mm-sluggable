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
            :method       => :parameterize,
            :scope        => nil,
            :max_length   => 256,
            :always_update => true, # allow always updating slug...
            :callback      => :before_validation,
            :callback_on   => nil,            
          }.merge(options)
          key slug_options[:key], String

          #before_validation :set_slug
          self.send(slug_options[:callback], :set_slug, {:on => slug_options[:callback_on]}) if slug_options[:callback] && slug_options[:callback_on]
          self.send(slug_options[:callback], :set_slug) if slug_options[:callback] && slug_options[:callback_on].nil?          
        end
      end

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
        return if (options[:key] == the_slug)
        # puts self.slug.inspect
        # puts the_slug.inspect

        conds = {}
        conds[options[:key]]   = the_slug
        conds[options[:scope]] = self.send(options[:scope]) if options[:scope]

        # first see if there is a equal slug
        used_slugs = self.class.where(conds)
        if (used_slugs.count > 0)
          last_digit = 0 # zero for last one...
          # if we are updating, check if the current slug is same as the one we want
          conds[options[:key]] = /(#{the_slug}-\d+)/
          used_slugs = self.class.where(conds).sort(options[:key].asc)
          new_slug_set = false
          used_slugs.each do |used_slug|
            # get the last digit through regex
            next_digit = used_slug.send(options[:key])[/(\d+)$/]
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