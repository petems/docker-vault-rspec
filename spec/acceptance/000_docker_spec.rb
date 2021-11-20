describe 'smoke checking Vault docker setup' do

  def port_in_use?(port)
    system("lsof -i:#{port}", out: '/dev/null')
  end

  context 'Docker' do
    it 'docker should be running' do
      expect { Docker.validate_version! }.to_not raise_error
    end

    it 'expect nothing running on port 8200' do 
      expect(port_in_use?(8200)).to be_falsey
    end
  end

  describe 'checking Vault container running and accessable' do
    include_examples 'an accessable Vault instance', { port: "8200", root_token: "ROOT" }
  end
end
