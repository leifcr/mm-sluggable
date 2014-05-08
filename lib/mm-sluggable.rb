require 'active_support'
require 'mongo_mapper'

module MongoMapper
  module Plugins
    module Sluggable
      extend ActiveSupport::Concern

      module ClassMethods
        def sluggable(to_slug = :title, options = {})
          class_attribute :slug_options

          self.slug_options = {
            to_slug:          to_slug,
            key:              :slug,
            method:           :parameterize,
            scope:            nil,
            max_length:       256,
            start:            1,
            always_update:    true, # allow always updating slug...
            callback:         :before_validation,
            callback_on:      nil,
          }.merge(options)
          key slug_options[:key], String

          #before_validation :set_slug
          self.send(slug_options[:callback], :set_slug, {:on => slug_options[:callback_on]}) if slug_options[:callback] && slug_options[:callback_on]
          self.send(slug_options[:callback], :set_slug) if slug_options[:callback] && slug_options[:callback_on].nil?
        end
      end

      def set_slug
        klass = self.class
        while klass.respond_to?(:single_collection_parent)
          superclass = klass.single_collection_parent
          if superclass && superclass.respond_to?(:slug_options)
            klass = superclass
          else
            break
          end
        end

        options = klass.slug_options

        if options[:always_update] == false
          return unless self.send(options[:key]).blank?
        end

        to_slug = self[options[:to_slug]]
        return if to_slug.blank?

        # previous_slug = self[:key]

        the_slug = raw_slug = to_slug.send(options[:method]).to_s[0...options[:max_length]]

        # no need to set, so return
        return if (self.send(options[:key]) == the_slug)
        # also do a regexp check,
        # verify if the previous slug is "almost" the same as we want without digits/extras
        return if (/(#{the_slug}-\d+)/.match(self.send(options[:key])) != nil)

        conds = {}
        conds[options[:key]]   = the_slug
        conds[options[:scope]] = self.send(options[:scope]) if options[:scope]

        # first see if there is a equal slug
        used_slugs = klass.where(conds).fields(options[:key])
        if (used_slugs.count > 0)
          last_digit = 0 # zero for last one...
          # if we are updating, check if the current slug is same as the one we want
          conds[options[:key]] = /(#{the_slug}-\d+)/
          used_slugs = klass.where(conds).fields(options[:key])
          used_slugs_array = Array.new
          used_slugs.each do |used_slug|
            used_slugs_array << used_slug.send(options[:key])[/(\d+)$/].to_i
          end
          used_slugs_array.sort!

          if used_slugs_array.length <= 0
            next_digit = options[:start]
          else
            prev_num = used_slugs_array.shift
            if used_slugs_array.length == 0
              next_digit = prev_num + 1
            else
              used_slugs_array.each do |slug_num|
                if ((slug_num - prev_num) > 1)
                  next_digit = prev_num + 1
                  break
                end
                next_digit = slug_num + 1
                prev_num = slug_num
              end
            end
          end
          the_slug = "#{raw_slug}-#{next_digit}"
        end

        self.send(:"#{options[:key]}=", the_slug)
      end
    end
  end
end
