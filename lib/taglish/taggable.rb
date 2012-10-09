module Taglish::Taggable

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
          self.tag_types = {}

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
      # NEXT: Write tests for just the functionality that I've got:
      # just test that the right class attributes are being set,
      # that the right methods are getting defined.
      # THEN: Copy/paste the save method, and think about how to implement
      # set_tag_list_on.
      # THEN: Implement tag_list_on.
      # LATER: Implement TagList (extending Array) to save back tags
      # if the user removes from/adds to the array.
      new_tag_types.each do |ptt|   # ptt is the plural form
        stt = ptt.to_s.singularize

        self.tag_types[ptt] = Taglish::TagType.new(ptt, scored, ordered)

        class_eval %(
          def #{stt}_list
            tag_list_on('#{ptt}')
          end

          def #{stt}_list=(new_tags)
            set_tag_list_on('#{ptt}', new_tags)
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
