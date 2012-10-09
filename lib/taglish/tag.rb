class Taglish::Tag < ActiveRecord::Base
  include Taglish::Util

  attr_accessible :name

  has_many :taggings, :dependent => :destroy, :class_name => 'Taglish::Tagging'

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 255

  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end

  def to_s
    name
  end

  def count
    read_attribute(:count).to_i
  end

  class << self
    private
    def comparable_name(str)
      str.mb_chars.downcase.to_s
    end
  end

end
