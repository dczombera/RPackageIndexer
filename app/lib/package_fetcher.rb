# frozen_string_literal: true
require 'open-uri'

module PackageFetcher
  def self.download_packages_index_file(repository_base_url)
    download("#{repository_base_url}/PACKAGES", 'PACKAGES')
  end

  def self.download(url, path)
    file = nil

    begin
      case io = URI.open(url)
      when StringIO, File
        Tempfile.open(path) do |f|
          f.write(io.read)
          file = f
        end
      when Tempfile
        io.close
        file = io
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.error("Error while trying to load #{url}: #{e}")
    end

    file
  end

  def self.package_description(name, base_url)
    compressed_package = download("#{base_url}/#{name}.tar.gz", name)
    extract_description_string_from_tar(compressed_package.path) unless compressed_package.nil?
  ensure
    compressed_package&.close
    compressed_package&.unlink # delete file
  end

  def self.package_url(package_metadata, base_url)
    "#{base_url}/#{package_metadata[:package]}/#{package_metadata[:version]}/.tar.gz"
  end

  private

    def self.extract_description_string_from_tar(file_name)
      tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(file_name))
      description = tar_extract.find { |entry| description?(entry.full_name) }
      description ? description.read : null
    ensure
      tar_extract.close
    end

    def self.description?(name)
      name.match(/DESCRIPTION$/)
    end
end
