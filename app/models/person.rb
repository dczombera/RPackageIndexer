class Person < ApplicationRecord
  has_and_belongs_to_many :authored_packages, class_name: 'Package', inverse_of: :authors, join_table: 'authors_packages'
  has_and_belongs_to_many :maintained_packages, class_name: 'Package', inverse_of: :maintainers, join_table: 'maintainers_packages'
end
