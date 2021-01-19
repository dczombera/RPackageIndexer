module PackageDescriptionParser
  CHARACTERS_IN_BRACKETS_REGEX = /\s*\[[^\]]*\]/.freeze
  NAME_EMAIL_REGEX = /([^\<]*)(?:\w*\<)?([^>]*)?/.freeze

  def self.parse_string(description)
    rows = description.split("\n")
    description_hash = create_description_hash(rows)
    parsed_description = parse_persons(description_hash)
    parsed_description = parse_publication_date(parsed_description)
    filter_description(parsed_description)
  end

  private

    def self.create_description_hash(rows)
      pairs = rows.map do |row|
        parts = row.split(':').map(&:strip)
        # Some rows can include colons as port of their value, e.g. publication date
        # We want to make sure to join parts that have been split but belong together
        value = parts.size > 2 ? parts.drop(1).join(':') : parts[1]
        [transform_key(parts[0]), value]
      end

      remove_invalid_pairs(pairs).to_h
    end

    def self.filter_description(description)
      result = {}
      description.each do |key, value|
        result[key] = value if %i[name version publication_date title description author maintainer].include?(key)
      end
      result
    end

    def self.parse_publication_date(description_hash)
      if description_hash.key?(:publication_date)
        publication_date = description_hash[:publication_date]
        begin
          description_hash[:publication_date] = DateTime.parse(publication_date)
        rescue Exception
          # Remove invalid date since we cannot use it
          description_hash.except!(:publication_date)
          Rails.logger.error "Parsing of publication date #{publication_date} failed."
        end
      end

      description_hash
    end

    def self.remove_invalid_pairs(pairs)
      pairs.select { |pair| pair.size == 2 }
    end

    def self.parse_persons(description_hash)
      %i[author maintainer].each do |key|
        next unless description_hash.key?(key)

        unparsed_name_str = description_hash[key]
        persons = []
        # Some names have the format 'Rok Blagus [aut, cre],  Sladana Babic [ctb]', which makes parsing more difficult.
        # Hence, we remove the brackets and anything in it.
        normalized_name_str = unparsed_name_str.gsub(CHARACTERS_IN_BRACKETS_REGEX, '')
        names = normalized_name_str.split(/,|and/).map(&:strip)
        names.each do |name|
          name_email_pairs = name.match(NAME_EMAIL_REGEX)&.captures
          person = {}
          person[:name] = name_email_pairs[0].strip unless name_email_pairs[0].blank?
          person[:email] = name_email_pairs[1].strip unless name_email_pairs[1].blank?
          persons << person unless person.empty?
        end

        description_hash[key] = persons
      end

      description_hash
    end

    def self.transform_key(key)
      key_sym = key.downcase.to_sym
      case key_sym
      when :package then
        :name
      when :"date/publication" then
        :publication_date
      else
        key_sym
      end
    end
end
