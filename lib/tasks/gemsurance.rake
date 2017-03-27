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
end
