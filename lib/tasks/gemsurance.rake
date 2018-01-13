namespace :gemsurance do
  desc 'Update all gemsurance reports'
  task update: :environment do
    Resource.all.each do |r|
      service = GemsuranceService.new r
      service.update_gems
      if r.fetch_status != 'successful'
        puts "#{r.name} failed to update:\n#{r.fetch_output}\n#{r.inspect}"
      end
    end
  end

  desc 'Fixes all GemInfos with too many current versions'
  task fix_invalid_versions: :environment do
    GemInfo.find_each do |info|
      versions = info.gem_versions.not_outdated.reject {|v| v.version_object.prerelease? }
      if versions.count > 1
        puts "Too many gem versions for #{info.name}:"
        versions.each {|v| puts "\t#{v.version}" }
        info.update_all_gem_versions!
        puts 'Fixed'
      end
    end
  end
end
