require 'test_helper'

class IndexUpdaterTest < ActiveSupport::TestCase
  def setup
    @temp_file = Tempfile.new('test')
  end

  def teardown
    @temp_file.unlink
  end

  test 'should create entry for single package' do
    package_index_fixture = file_fixture('index_for_abe.txt')
    expected_rok = Person.new(name: 'Rok Blagus', email: 'rok.blagus@mf.uni-lj.si')
    expected_sladana = Person.new(name: 'Sladana Babic')

    IndexUpdater.run(package_index_fixture.realpath, package_index_fixture.dirname)

    assert_equal(1, Package.count)
    package = Package.first
    assert_equal(package.name, 'abe')
    assert_equal(package.publication_date, '2017-10-30 09:14:07')
    assert_equal(package.title, 'Augmented Backward Elimination')

    assert_equal(2, Person.count)
    assert_equal(Person.where(name: expected_rok.name).first.email, expected_rok.email)
    assert_equal(Person.where(name: expected_sladana.name).count, 1)
  end
end
