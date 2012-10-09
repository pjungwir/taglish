require 'active_support/core_ext/module/delegation'

##
# Contains a list of strings.
# Works like an array.
class Taglish::TagList < Array
  attr_accessor :tag_type
  attr_accessor :taggable

  def initialize(tag_type, *args)
    self.tag_type = tag_type  or raise "tag_type is required"
    add(*args)
  end

  ##
  # Add tags to the tag_list. Duplicate or blank tags will be ignored.
  #
  # Example:
  #   tag_list.add("Fun", "Happy")
  #   tag_list.add("Fun, Happy", :parse => true)
  def add(*names)
    extract_and_apply_options!(names)
    concat(names)
    clean!
    self
  end

  ##
  # Returns a new TagList using the given tag string.
  #
  # Example:
  #   tag_list = TagList.from("One , Two,  Three")
  #   tag_list # ["One", "Two", "Three"]
  def self.from(tag_type, string)
    string = string.join(tag_type.glue) if string.respond_to?(:join)

    new(tag_type).tap do |tag_list|
      string = string.to_s.dup

      # Parse the quoted tags
      d = tag_type.delimiter
      d = d.join("|") if d.kind_of?(Array) 
      string.gsub!(/(\A|#{d})\s*"(.*?)"\s*(#{d}\s*|\z)/) { tag_list << $2; $3 }
      string.gsub!(/(\A|#{d})\s*'(.*?)'\s*(#{d}\s*|\z)/) { tag_list << $2; $3 }

      tag_list.add(string.split(Regexp.new d))
    end
  end

  ##
  # Remove specific tags from the tag_list.
  # Use the <tt>:parse</tt> option to add an unparsed tag string.
  #
  # Example:
  #   tag_list.remove("Sad", "Lonely")
  #   tag_list.remove("Sad, Lonely", :parse => true)
  def remove(*names)
    extract_and_apply_options!(names)
    if tag_type.scored
      delete_if { |name| names.include?(name.sub(/^(.+):(\d+)$/, '\1')) }
    else
      delete_if { |name| names.include?(name) }
    end
    self
  end

  ##
  # Transform the tag_list into a tag string suitable for edting in a form.
  # The tags are joined with <tt>TagList.delimiter</tt> and quoted if necessary.
  #
  # Example:
  #   tag_list = TagList.new("Round", "Square,Cube")
  #   tag_list.to_s # 'Round, "Square,Cube"'
  def to_s
    tags = frozen? ? self.dup : self
    tags.send(:clean!)

    tags.map do |name|
      d = tag_type.delimiter
      d = Regexp.new d.join("|") if d.kind_of? Array
      name.index(d) ? "\"#{name}\"" : name
    end.join(tag_type.glue)
  end

  def to_tagging_array
    map { |name|
      ar = tag_type.name_and_score(name)
      Taglish::Tagging.new(:name => ar[0], :score => ar[1])
    }
  end

  private

  # Remove whitespace, duplicates, and blanks.
  def clean!
    # Do this in self.from instead, or wherever we parse from strings:
    reject!(&:blank?)
    map!(&:strip)
    map!(&:downcase)     if tag_type.force_lowercase
    map!(&:parameterize) if tag_type.force_parameterize

    uniq!
  end
   
  def extract_and_apply_options!(args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.assert_valid_keys :parse

    if options[:parse]
      args.map! { |a| self.class.from(a) }
    end

    args.flatten!
  end
end
