module Taglish::Core


  def tag_list_on(context)
  end

  def set_tag_list_on(context)
  end

  def all_tags_list_on(context)
    raise "TODO LATER"
  end

  def add_tag_on(context, tag)
  end

  # context is plural
  def tags_have_score?(context)
    tag_types[context].scored?
  end

  # context is plural
  def tags_have_order?(context)
    tag_types[context].ordered?
  end

  def taggable?
    self.class.taggable?
  end

end
