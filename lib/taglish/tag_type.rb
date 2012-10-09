class Taglish::TagType
  attr_accessor :name, :scored, :ordered, :delimiter, :score_delimiter

  def initialize(name, scored=false, ordered=false)
    self.name = name
    self.scored = scored
    self.ordered = ordered
    self.delimiter = ','
    self.score_delimiter = ':'
  end

  def scored?
    scored
  end

  def ordered?
    ordered
  end

end
