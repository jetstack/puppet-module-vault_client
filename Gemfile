source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place_or_version, fake_version = nil)
  if place_or_version =~ %r{\A(git[:@][^#]*)#(.*)}
    [fake_version, { git: Regexp.last_match(1), branch: Regexp.last_match(2), require: false }].compact
  elsif place_or_version =~ %r{\Afile:\/\/(.*)}
    ['>= 0', { path: File.expand_path(Regexp.last_match(1)), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

def gem_type(place_or_version)
  if place_or_version =~ %r{\Agit[:@]}
    :git
  elsif !place_or_version.nil? && place_or_version.start_with?('file:')
    :file
  else
    :gem
  end
end

ruby_version_segments = Gem::Version.new(RUBY_VERSION.dup).segments
minor_version = ruby_version_segments[0..1].join('.')

group :development do
  gem "puppet-module-posix-default-r#{minor_version}", require: false, platforms: [:ruby]
  gem "puppet-module-posix-dev-r#{minor_version}",     require: false, platforms: [:ruby]
  gem 'fast_gettext', '1.1.0',                         require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.1.0')
  gem 'fast_gettext',                                  require: false if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.1.0')
  gem 'json',                                          require: false
  gem 'json_pure', '<= 2.0.1',                         require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.0.0')
  gem 'puppet-lint',                                   require: false
  gem 'semantic_puppet',                               require: false
end

group :system_tests do
  gem "puppet-module-posix-system-r#{minor_version}", require: false, platforms: 'ruby'
  gem 'beaker',                                       *location_for(ENV['BEAKER_VERSION'] || '>= 3')
  gem 'beaker-abs',                                   *location_for(ENV['BEAKER_ABS_VERSION'] || '~> 0.1')
  gem 'beaker-hostgenerator',                         *location_for(ENV['BEAKER_HOSTGENERATOR_VERSION'])
  gem 'beaker-pe',                                    require: false
  gem 'beaker-rspec',                                 *location_for(ENV['BEAKER_RSPEC_VERSION'])
  gem 'puppet-blacksmith', '~> 3.4',                  require: false
end

puppet_version = ENV['PUPPET_GEM_VERSION']
puppet_type = gem_type(puppet_version)
facter_version = ENV['FACTER_GEM_VERSION']
hiera_version = ENV['HIERA_GEM_VERSION']

def puppet_older_than?(version)
  puppet_version = ENV['PUPPET_GEM_VERSION']
  !puppet_version.nil? &&
    Gem::Version.correct?(puppet_version) &&
    Gem::Requirement.new("< #{version}").satisfied_by?(Gem::Version.new(puppet_version.dup))
end

gems = {}

gems['puppet'] = location_for(puppet_version)

# If facter or hiera versions have been specified via the environment
# variables, use those versions. If not, and if the puppet version is < 3.5.0,
# use known good versions of both for puppet < 3.5.0.
if facter_version
  gems['facter'] = location_for(facter_version)
elsif puppet_type == :gem && puppet_older_than?('3.5.0')
  gems['facter'] = ['>= 1.6.11', '<= 1.7.5', require: false]
end

if hiera_version
  gems['hiera'] = location_for(ENV['HIERA_GEM_VERSION'])
elsif puppet_type == :gem && puppet_older_than?('3.5.0')
  gem['hiera'] = ['>= 1.0.0', '<= 1.3.0', require: false]
end

gems.each do |gem_name, gem_params|
  gem gem_name, *gem_params
end

# Evaluate Gemfile.local and ~/.gemfile if they exist
extra_gemfiles = [
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end
# vim: syntax=ruby
