module IndexUpdater
  def self.run(index_file, base_url)
    package_metadata = {}

    file = index_file.open
    file.each_line do |line|
      # Reached end of metadata for a specific package
      if newline?(line) || file.eof?
        package_description_string = PackageFetcher.package_description(package_name(package_metadata), base_url)
        update_index_with_description_string(package_description_string) unless package_description_string.nil?
        package_metadata = {}
      else
        part_of_package_file_name(line)
        parsed_line = parse_line(line)
        package_metadata[parsed_line[0]] = parsed_line[1]
      end
    end
  end

  private

    def self.update_index_with_description_string(description_string)
      package_description = PackageDescriptionParser.parse_string(description_string)
      update_package_index(package_description)
    end

    def self.update_package_index(description)
      ActiveRecord::Base.transaction do
        begin
          # Fails if package already exists due to unique constraint [:name, :version] at DB level
          package = Package.create!(description.except(:author, :maintainer))
          maintainers = description[:maintainer].map { |maintainer| Person.find_or_create_by(maintainer) }
          authors = description[:author].map { |author| Person.find_or_create_by(author) }
          package.maintainers << maintainers
          package.authors << authors
          package.save!
          Rails.logger.info("Package #{package.name} was created!")
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Error while updating the package index: #{e}")
        rescue ActiveRecord::RecordNotUnique => e
          Rails.logger.info("Record already exists: #{e}")
        end
      end
    end

    def self.newline?(line)
      line == "\n"
    end

    def self.part_of_package_file_name(line)
      key = line.split(':')[0]
      %w[Package Version].include?(key)
    end

    def self.parse_line(line)
      parts = line.split(':')
      parts.map.with_index do |part, index|
        part.strip!
        # Use symbol for key
        index.zero? ? part.downcase.to_sym : part
      end
    end

    def self.package_name(metadata)
      "#{metadata[:package]}_#{metadata[:version]}"
    end
end
