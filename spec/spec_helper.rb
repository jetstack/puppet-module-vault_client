require 'puppetlabs_spec_helper/module_spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  RSpec.configure do |c|
    c.before :each do
      Puppet.settings[:strict] = :error
    end
  end
end

RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end

begin
  require 'spec_helper_local'
end
