module Taglish::Core

  def self.included(base)
    base.class_eval do
      after_save :save_tags
    end
  end

  # Returns an array of Tags
  # context should be plural
  def tags_on(context)
    taggings.on(context).map{|tg| tg.tag}
  end

  # Returns an array of Taggings
  # context should be plural
  def taggings_on(context)
    q = taggings.includes(:tag).where(%Q{
                 #{Taglish::Tagging.table_name}.context = ?
             AND #{Taglish::Tagging.table_name}.tagger_id IS NULL}, context.to_s)
    q = q.order("#{Taglish::Tagging.table_name}.id") if tags_have_order?(context)
    q
  end

  # Returns an array of strings
  def tag_list_on(tag_type)
    n = tag_list_variable_name_for(tag_type)
    instance_variable_get(n) ||
      instance_variable_set(n,
        Taglish::TagList.new(tag_type, *taggings_on(tag_type.name).map(&:to_s)))
  end

  def set_tag_list_on(tag_type, new_list)
    n = tag_list_variable_name_for(tag_type)
    mark_tag_list_as_changed(tag_type, new_list)
    instance_variable_set(n, Taglish::TagList.from(tag_type, new_list))
  end

  def taggings_by_name(context)
    Hash[taggings_on(context).map{|tg| [tg.name, tg]}]
  end

  def mark_tag_list_as_changed(tag_type, new_list)
    value = new_list.is_a?(Array) ? new_list.join(', ') : new_list
    attrib = tag_list_attribute_name_for(tag_type)

    old = changed_attributes[attrib]
    if old.nil?
      old = tag_list_on(tag_type).to_s
      if old.to_s != value.to_s
        changed_attributes[attrib] = old
        tag_list_changed!(tag_type)
      end
    else
      if old.to_s == value.to_s
        changed_attributes.delete(attrib)
        tag_list_changed!(tag_type, false)
      end
    end
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

  def tag_list_changed?(tag_type)
    instance_variable_get(dirty_tag_list_variable_name_for(tag_type))
  end

  def tag_list_changed!(tag_type, changed=true)
    instance_variable_set(dirty_tag_list_variable_name_for(tag_type), changed)
  end

  def reload(*args)
    self.class.tag_types.each do |tt_name, tt|
      instance_variable_set(tag_list_variable_name_for(tt), nil)
      tag_list_changed!(tt, false)
    end
   
    super(*args)
  end

  def save_tags
    self.class.tag_types.each do |tag_type_name, tag_type|
      # next unless changed_attributes[tag_list_attribute_name_for(tag_type)]
      next unless tag_list_changed?(tag_type)

      new_tag_list = instance_variable_get(tag_list_variable_name_for(tag_type))

      # Tag objects for the new set of taggings:
      # tags = tag_type.find_or_create_tags(*new_tags)

      # Tagging objects for the new set of taggings (not persisted):
      # new_taggings = Hash[new_tag_list.to_tagging_array.map{|tg| [tg.name, tg]}]
      new_taggings = new_tag_list.to_tagging_array

      # Tagging objects for the previous set of taggings:
      current_taggings = taggings_by_name(tag_type_name)

      if tag_type.ordered?
        raise "TODO: Ordering not supported yet"
      else
        new_taggings.each do |tg|
          old_tg = current_taggings[tg.name]
          if old_tg
            if old_tg.score != tg.score
              old_tg.update_attribute(:score, tg.score)
            end
            current_taggings.delete tg.name
          else
            tg.taggable = self
            tg.tag = Taglish::Tag.find_or_create_by_name(tg.name)
            tg.context = tag_type_name
            tg.save!
          end
        end
      end

      # Remove unused taggings:
      Taglish::Tagging.destroy_all :id => current_taggings.values.map(&:id)
    end

    true
  end

  private

  def tag_list_variable_name_for(tag_type)
    "@#{tag_type.name}_list"
  end

  def tag_list_attribute_name_for(tag_type)
    "#{tag_type.name.to_s.singularize}_list"
  end

  def dirty_tag_list_variable_name_for(tag_type)
    "#{tag_list_variable_name_for(tag_type)}_changed"
  end

end
