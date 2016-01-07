module Bibliotheca::IO
  class Operation
    attr_accessor :log, :bot

    def initialize(bot)
      @bot = bot
      @log = new_log
    end

    def with_local_repo(&block)
      Dir.mktmpdir("mumuki.#{self.class.name}") do |dir|
        bot.clone_into repo, dir, &block
      end
    end

    def run!
      puts "#{self.class.name} : running before run hook for repository #{repo.full_name}"
      before_run_in_local_repo

      log.with_error_logging do
        with_local_repo do |dir, local_repo|
          puts "#{self.class.name} : running run hook for repository #{repo.full_name}"
          run_in_local_repo dir, local_repo
        end
      end

      puts "#{self.class.name} : running after run hook repository #{repo.full_name}"
      after_run_in_local_repo

      Bibliotheca::IO::AtheneumExporter.run!(guide)
    end

    def before_run_in_local_repo
    end

    def after_run_in_local_repo
    end

    def run_in_local_repo(dir, local_repo)
    end

    private

    def new_log
      Bibliotheca::IO::Log.new
    end
  end
end
