class Package < ApplicationRecord
  has_and_belongs_to_many :authors, class_name: 'Person', join_table: 'authors_packages'
  has_and_belongs_to_many :maintainers, class_name: 'Person', join_table: 'maintainers_packages'
end
