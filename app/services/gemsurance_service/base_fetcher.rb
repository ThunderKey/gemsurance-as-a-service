# frozen_string_literal: true

class GemsuranceService::BaseFetcher
  def self.logger
    GemsuranceService.logger
  end

  def logger
    self.class.logger
  end

  def self.run *cmds, chdir:
    cmd = cmds.join(' ')
    logger.debug "#{name}: Called method \"#{cmd}\" within \"#{chdir}\""
    Open3.capture2e cmd, chdir: chdir
  end

  def self.run_in_seperate_env *cmds, chdir:
    paths = ENV['PATH'].split(':')
    paths.each {|p| p.gsub! Rails.root.to_s, chdir }
    gemsets = paths.select {|p| p =~ %r{/gems/} }
    gem_paths = gemsets.map {|g| g.gsub(%r{/bin}, '') }.uniq
    gem_homes = gem_paths.map {|g| g.gsub(%r{@[^/]+\z}, '') }.uniq
    run 'env', '-i',
      %Q{HOME="#{ENV['HOME']}"},
      %Q{PATH="#{paths.join ':'}"},
      %Q{USER="#{ENV['USER']}"},
      %Q{GEM_HOME="#{gem_homes.join ':'}"},
      %Q{GEM_PATH="#{gem_paths.join ':'}"},
      *cmds, chdir: chdir
  end
end
