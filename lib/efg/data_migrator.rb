require 'logger'
require 'efg/data_migration'

module EFG
  class DataMigrator
    def initialize(options = {})
      @path = options[:path] || Rails.root.join("db/data_migration")
      @logger = options[:logger] || Logger.new($stderr)
    end

    def migrations
      files = if ENV["VERSION"]
        Dir["#{@path}/#{ENV["VERSION"]}_*.rb"]
      else
        Dir["#{@path}/*_*.rb"]
      end
      files.map do |f|
        EFG::DataMigration.new(f, logger: @logger)
      end
    end

    def due
      migrations.select(&:due?)
    end

    def run
      if due.any?
        @logger.info "Running #{due.size} data #{"migration".pluralize(due.size)}..."
        failures = []
        due.sort_by(&:version).each do |migration|
          migration.run failures
        end
        if failures.any?
          raise Exception.new("Some migrations failed - please use trace to find out more\n" \
            + failures.join("\n") + "\n\n")
        end
      else
        @logger.info "No data migrations pending."
      end
    end
  end
end
