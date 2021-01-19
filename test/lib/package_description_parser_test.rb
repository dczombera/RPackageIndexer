require 'test_helper'

class PackageDescriptionParserTest < ActiveSupport::TestCase
  test 'should parse description string' do
    description_string = <<-EOF
    Package: abe
    Type: Package
    Title: Augmented Backward Elimination
    Version: 3.0.1
    Date: 2017-10-25
    Author: Rok Blagus [aut, cre],  Sladana Babic [ctb]
    Maintainer: Rok Blagus <rok.blagus@mf.uni-lj.si>
    Description: Performs augmented backward elimination and checks the stability of the obtained model. Augmented backward elimination combines significance or information based criteria with the change in estimate to either select the optimal model for prediction purposes or to serve as a tool to obtain a practically sound, highly interpretable model. More details can be found in Dunkler et al. (2014) <doi:10.1371/journal.pone.0113677>. 
    Date/Publication: 2017-10-30 09:14:07 UTC
    EOF

    description = PackageDescriptionParser.parse_string(description_string)
    assert_equal("abe", description[:name])
    assert_equal("Augmented Backward Elimination", description[:title])
    assert_equal([{ name: "Rok Blagus" }, { name: "Sladana Babic" }], description[:author])
    assert_equal([{ name: "Rok Blagus", email: "rok.blagus@mf.uni-lj.si" }], description[:maintainer])
    assert_equal(DateTime.parse("2017-10-30 09:14:07 UTC"), description[:publication_date])
  end
end
