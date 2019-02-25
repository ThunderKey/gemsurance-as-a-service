# frozen_string_literal: true

class GemsuranceService
  class LocalFetcher < BaseFetcher
    def self.update_gemsurance_report resource, file
      output = exit_code = nil
      3.times do
        output, exit_code = run_gemsurance resource, file
        break unless output.include? 'Psych::SyntaxError'

        logger.error "Found Psycn::SyntaxError in output: #{output}"
      end
      [output, exit_code]
    end

    def self.errors resource
      return {} if resource.path.blank?

      return {path: :does_not_exist} unless File.exist? resource.path

      return {path: :not_a_directory} unless File.directory? resource.path

      {}
    end

    def self.run_gemsurance resource, file
      run_in_seperate_env 'gemsurance', '--format', 'yml', '--output', file, chdir: resource.path
    end
  end
end
