require 'test_helper'

class PackageFetcherTest < ActiveSupport::TestCase
  def setup
    @temp_file = Tempfile.new('test')
  end

  def teardown
    @temp_file.unlink
  end

  test 'should download file to correct path' do
    packages_fixture = file_fixture('packages.txt')

    @temp_file = PackageFetcher.download(packages_fixture.realpath, 'packages')
    assert_equal(packages_fixture.size, @temp_file.size)
  end

  test 'should get correct package description' do
    package_tar_fixture = file_fixture('abe_3.0.1.tar.gz')
    expected_description_string = "Package: abe\nType: Package\nTitle: Augmented Backward Elimination\nVersion: 3.0.1\nDate: 2017-10-25\nAuthors@R: c(person(c(\"Rok\",\"Blagus\"),role=c(\"aut\",\"cre\"),email=\"rok.blagus@mf.uni-lj.si\"),person(\"Sladana\", \"Babic\", role = \"ctb\",\n             email = \"sladja93babic@gmail.com\"))\nAuthor: Rok Blagus [aut, cre],  Sladana Babic [ctb]\nMaintainer: Rok Blagus <rok.blagus@mf.uni-lj.si>\nDescription: Performs augmented backward elimination and checks the stability of the obtained model. Augmented backward elimination combines significance or information based criteria with the change in estimate to either select the optimal model for prediction purposes or to serve as a tool to obtain a practically sound, highly interpretable model. More details can be found in Dunkler et al. (2014) <doi:10.1371/journal.pone.0113677>. \nLicense: GPL (>= 2)\nRoxygenNote: 6.0.1\nNeedsCompilation: no\nPackaged: 2017-10-27 14:54:33 UTC; rblagus\nRepository: CRAN\nDate/Publication: 2017-10-30 09:14:07 UTC\n"

    description = PackageFetcher.package_description('abe_3.0.1', package_tar_fixture.dirname.to_s)
    assert_equal(expected_description_string, description)
  end
end