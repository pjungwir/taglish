class TaggableModel < ActiveRecord::Base
  taglish
  taglish_on :languages
  taglish_on :skills
  taglish_on :needs, :offerings
  has_many :untaggable_models
end

class CachedModel < ActiveRecord::Base
  taglish
end

class OtherCachedModel < ActiveRecord::Base
  taglish_on :languages, :statuses, :glasses
end

class OtherTaggableModel < ActiveRecord::Base
  taglish_on :tags, :languages
  taglish_on :needs, :offerings
end

class InheritingTaggableModel < TaggableModel
end

class AlteredInheritingTaggableModel < TaggableModel
  taglish_on :parts
end

class TaggableUser < ActiveRecord::Base
  # TODO LATER
  # acts_as_tagger
end

class InheritingTaggableUser < TaggableUser
end

class UntaggableModel < ActiveRecord::Base
  belongs_to :taggable_model
end

class NonStandardIdTaggableModel < ActiveRecord::Base
  primary_key = "an_id"
  taglish
  taglish_on :languages
  taglish_on :skills
  taglish_on :needs, :offerings
  has_many :untaggable_models
end

class OrderedTaggableModel < ActiveRecord::Base
  ordered_taglish
  ordered_taglish_on :colours
end

class OrderedUnorderedTaggableModel < ActiveRecord::Base
  taglish_on :skills
  ordered_taglish_on :colours
  taglish_on :needs, :offerings
end

class ScoredTaggableModel < ActiveRecord::Base
  scored_taglish_on :question_counts
end
