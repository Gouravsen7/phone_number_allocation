class AllotedNumber < ApplicationRecord

  validates_presence_of :first_name, :last_name
  validates_format_of :number, with:  /\d[0-9]\)*\z/ , message: "Positive number are allowed", allow_blank: true
  validate :valid_number

  before_validation :strip_dash_from_number
  before_create :check_available_and_assign_number

  def check_available_and_assign_number
    if self.number && (already_alloted_numbers.include? self.number)
      self.number = nil
    end
    get_available_number
  end

  def strip_dash_from_number
    self.number = self.number.gsub('-', '').gsub(' ', '') if self.number
  end

  def valid_number
    return true unless self.number
    if (self.number.to_i < 1111111111) || (self.number.to_i > 9999999999)
      errors.add(:number, "Enter a valid number('111-111-1111' - '999-999-9999')")
    end
  end

  def get_available_number
    until self.number do
      self.number = subscriber_number
    end
    self.number
  end

  def already_alloted_numbers
    AllotedNumber.pluck(:number)
  end
  
  def subscriber_number
   random_number = rand.to_s[2..11]
   ((random_number.to_i > 1111111110) && (random_number.to_i < 10000000000) && !already_alloted_numbers.include?(random_number)) ? random_number : nil
  end
end
