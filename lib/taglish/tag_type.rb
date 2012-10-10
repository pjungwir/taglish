class Taglish::TagType
  attr_accessor :name, :scored, :ordered, :delimiter, :score_delimiter,
    :force_parameterize, :force_lowercase

  def initialize(name, opts={})
    opts = {
      :scored => false,
      :ordered => false,
      :delimiter => Taglish::DEFAULT_DELIMITER,
      :score_delimiter => Taglish::DEFAULT_SCORE_DELIMITER,
      :force_parameterize => false,
      :force_lowercase => false
    }.merge(opts)
    
    self.name               = name
    self.scored             = opts[:scored]
    self.ordered            = opts[:ordered]
    self.delimiter          = opts[:delimiter]
    self.score_delimiter    = opts[:score_delimiter]
    self.force_parameterize = opts[:force_parameterize]
    self.force_lowercase    = opts[:force_lowercase]
  end

  def scored?
    scored
  end

  def ordered?
    ordered
  end

  def name_and_score(tag_str)
    if scored
      tag_str =~ /^(.+):(\d+)$/ or raise "Scored tag has no score: #{tag_str}"
      [$1, $2.to_i]
    else
      [tag_str, nil]
    end
  end

  def find_or_create_tags(*tag_list)
    return [] if tag_list.empty?
    
    list = scored ? tag_list.map{|t| name_and_score(t)[0]} : tag_list

    existing_tags = Tag.named_any(list).all
    new_tag_names = list.reject do |name|
      name = comparable_name(name)
      existing_tags.any? {|tag| comparable_name(tag.name) == name}
    end
    created_tags = new_tag_names.map {|name| Tag.create(:name => name) }

    existing_tags + created_tags
  end

  ##
  # Returns the proper string used to join tags:
  # basically the first choice of delimiters,
  # with a space after each delimiter.
  def glue
    d = delimiter.kind_of?(Array) ? delimiter[0] : delimiter
    d.ends_with?(" ") ? d : "#{d} "
  end

end
