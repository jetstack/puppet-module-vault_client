require 'spec_helper_acceptance'

describe 'vault_client class', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'runs successfully' do
    pp = "class { 'vault_client': init_token => 'init-token-all', init_role => 'test-all',}"

    apply_manifest(pp, catch_failures: true) do |r|
      expect(r.stderr).not_to match(%r{error}i)
    end

    apply_manifest(pp, catch_failures: true) do |r|
      expect(r.stderr).not_to eq(%r{error}i)
      expect(r.exit_code).to be_zero
    end
  end
end
