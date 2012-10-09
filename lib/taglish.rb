require "active_record"
require "active_record/version"
require "action_view"

require "digest/sha1"

module Taglish
  DELIMITER = ','

end


require 'taglish/util'
require 'taglish/tag_type'
require 'taglish/tag'
require 'taglish/taggable'
require 'taglish/tagging'
require 'taglish/core'


if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Taglish::Taggable
  # TODO LATER:
  # ActiveRecord::Base.send :include, Taglish::Tagger
end

if defined?(ActionView::Base)
  # TODO:
  # ActionView::Base.send :include, Taglish::TagsHelper
end

