class CreatePeopleAndPackages < ActiveRecord::Migration[6.0]
  def change
    create_table :packages do |t|
      t.string :name
      t.string :version
      t.datetime :publication_date
      t.string :title
      t.text :description

      t.timestamps

      t.index %i[name version], unique: true
    end

    create_table :people do |t|
      t.string :name
      t.string :email

      t.timestamps

      t.index :name, unique: true
    end

    create_table :authors_packages do |t|
      t.integer :person_id
      t.integer :package_id
      t.index :package_id
    end

    create_table :maintainers_packages do |t|
      t.integer :person_id
      t.integer :package_id
      t.index :package_id
    end
  end
end
