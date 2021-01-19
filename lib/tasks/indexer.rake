require 'rubygems/package'

namespace :indexer do
  desc 'Updates the packages index'
  task update: :environment do
    base_url = ENV.fetch('BASE_URL')
    begin
      index_file = PackageFetcher.download_packages_index_file(base_url)
      IndexUpdater.run(index_file, base_url)
    ensure
      index_file.close
      index_file.unlink # delete
    end
  end
end
