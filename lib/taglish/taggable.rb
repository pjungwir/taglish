module Taglish::Taggable

  SCORED_TAG_REGEX = /^(.+):(-?\d+)$/

  def taggable?
    false
  end

  def taglish
    taglish_on(:tags)
  end

  def ordered_taglish
    ordered_taglish_on(:tags)
  end

  def scored_taglish
    scored_taglish_on(:tags)
  end

  ##
  # Make a model taggable on specified contexts.
  #
  # @param [Array] tag_types An array of taggable contexts
  #
  # Example:
  #   class User < ActiveRecord::Base
  #     scored_taglish_on :languages, :skills
  #   end
  def scored_taglish_on(*tag_types)
    taggable_on(false, true, tag_types)
  end

  ##
  # Make a model taggable on specified contexts.
  #
  # @param [Array] tag_types An array of taggable contexts
  #
  # Example:
  #   class User < ActiveRecord::Base
  #     taglish_on :languages, :skills
  #   end
  def taglish_on(*tag_types)
    taggable_on(false, false, tag_types)
  end

  ##
  # Make a model taggable on specified contexts.
  #
  # @param [Array] tag_types An array of taggable contexts
  #
  # Example:
  #   class User < ActiveRecord::Base
  #     scored_taglish_on :languages, :skills
  #   end
  def ordered_taglish_on(*tag_types)
    taggable_on(true, false, tag_types)
  end

  private

  def taggable_on(ordered, scored, *new_tag_types)
    # Assume new_tag_types has plural forms, like `skills`:
    new_tag_types = new_tag_types.to_a.flatten.compact.map(&:to_sym)
    unless taggable?
      class_eval do
        class_attribute :tag_types
        self.tag_types = HashWithIndifferentAccess.new

        has_many :taggings, :as => :taggable, :dependent => :destroy,
          :include => :tag, :class_name => "Taglish::Tagging"
        has_many :all_tags, :through => :taggings, :source => :tag,
          :class_name => "Taglish::Tag"

        def self.taggable?
          true
        end

        include Taglish::Util
        include Taglish::Core
      end
    end
    # THEN: Copy/paste the save method, and think about how to implement
    # set_tag_list_on.
    # THEN: Implement tag_list_on.
    # LATER: Implement TagList (extending Array) to save back tags
    # if the user removes from/adds to the array.
    new_tag_types.each do |ptt|   # ptt is the plural form
      stt = ptt.to_s.singularize

      tag_type = Taglish::TagType.new(ptt, :scored => scored, :ordered => ordered)
      self.tag_types[ptt] = tag_type

      taggings_scope_name = ptt.to_sym
      taggings_order = tag_type.ordered ? "#{Taglish::Tagging.table_name}.id" : nil

      class_eval do
        has_many taggings_scope_name, :as => :taggable,
                                      :dependent => :destroy,
                                      :include => :tag,
                                      :class_name => 'Taglish::Tagging',
                                      :conditions => ["#{Taglish::Tagging.table_name}.context = ?", ptt],
                                      :order => taggings_order

        has_many "#{stt}_tags".to_sym, :through => taggings_scope_name,
                                       :source => :tag,
                                       :class_name => "Taglish:Tag",
                                       :order => taggings_order

      end

      class_eval %(
        def #{stt}_list
          tag_list_on(tag_types['#{ptt}'])
        end

        def #{stt}_list=(new_tags)
          set_tag_list_on(tag_types['#{ptt}'], new_tags)
        end

        def all_#{ptt}
          all_tags_list_on('#{ptt}')
        end

        def add_#{stt}(tag)
          add_tag_on('#{ptt}', tag)
        end
      )

      if scored
        class_eval %(
          def score_for_#{stt}(tag)
            raise "TODO"
          end

          def set_score_for_#{stt}(tag, score)
            set_score_for_tag_on('#{ptt}', tag, score)
          end
        )
      end
    end
  end

end
