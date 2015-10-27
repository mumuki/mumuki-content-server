module GitIo
  class JsonWrapper
    def initialize(json)
      @json = defaults.merge(json)
    end

    def as_json(options)
      @json.as_json(options)
    end

    def method_missing(name, *args)
      @json[name]
    end
  end

  class Exercise < JsonWrapper
    def initialize
      {}
    end
  end

  class Guide < JsonWrapper
    def defaults
      {beta: false,
       learning: false,
       original_id_format: '%05d'}
    end

    def exercises
      @exercises ||= @json[:exercises].map { |e| OpenStruct.new e }
    end

    def language
      @language ||= Language.find_by_name(@json[:language])
    end

    def format_original_id(exercise)
      self.original_id_format % exercise[:original_id]
    end
  end
end