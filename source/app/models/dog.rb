class Dog < ActiveRecord::Base
  include USGeography

  validates :name, :license, :owner_id, { :presence => true }
  validates :license, { :uniqueness => true }
  validates :license, format: { with: /\A[A-Z]{2}\-/ }
  validates :age, { :numericality => { greater_than_or_equal_to: 0 },
                    :allow_blank  => true }

  validate :license_from_valid_state

  def license_from_valid_state
    unless self.license.instance_of? String
      errors.add :license, "must be a string"
      return
    end

    abbreviation = self.license[0..1]
    unless valid_state_abbreviation? abbreviation
      errors.add :license, "must be from a valid US state"
    end
  end
end
