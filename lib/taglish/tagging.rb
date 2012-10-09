class Taglish::Tagging < ActiveRecord::Base
  include Taglish::Util

  attr_accessible :tag, :tag_id, :context, :taggable, :taggable_type, :taggable_id,
    :tagger, :tagger_type, :tagger_id, :score

  belongs_to :tag, :class_name => 'Taglish::Tag'
  belongs_to :taggable, :polymorphic => true
  belongs_to :tagger, :polymorphic => true

  validates_presence_of :context
  validates_presence_of :tag_id
  validates_uniqueness_of :tag_id, :scope => [ :taggable_type, :taggable_id, :context, :tagger_id, :tagger_type ]

  after_destroy :remove_unused_tags

  def name
    tag.name
  end

  def ==(object)
    super || (
      object.is_a?(Tagging) &&
      context == object.context &&
      name == object.name &&
      score == object.score)
  end

  def to_s
    if taggable.tags_have_score?(context)
      "#{name}:#{score}"
    else
      name
    end
  end

  private

  def remove_unused_tags
    if taggable.remove_unused_tags_for?(context)
      tag.destroy if tag.taggings.count.zero?
    end
  end

end
