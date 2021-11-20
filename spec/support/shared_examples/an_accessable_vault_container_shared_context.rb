shared_examples 'an accessable Vault instance' do |options = {}|
  before :all do

    @port = options[:port]
    @root_token = options[:root_token]

    image = Docker::Image.create('fromImage' => 'vault:1.3.10')
    container_opts = {
      'name' => 'vault-rspec',
      'Image' => image.id,
      'ExposedPorts' => { "#{@port}/tcp" => {} },
      'HostConfig' => {
        'PortBindings' => {
          "#{@port}/tcp" => [{HostPort: @port}]
        }
      },
      'Env' => [
        "VAULT_DEV_ROOT_TOKEN_ID=#{@root_token}",
        "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:#{@port}",
        "VAULT_ADDR=http://0.0.0.0:#{@port}",
        "VAULT_TOKEN=ROOT",
        "SKIP_SETCAP=true",
        "VAULT_DISABLE_MLOCK=true"
      ],
    }

    @container = Docker::Container.create container_opts
    @container.start!

    if ENV['DEBUG']
      Thread.new do
        @container.streaming_logs stdout: true, stderr: true, follow: true do |stream, chunk|
          puts "[#{stream}] #{chunk}"
        end
      end
    end
  end

  describe 'when starting a Vault container' do
    subject { @container }

    it { is_expected.to_not be_nil }
    it { is_expected.to wait_until_output_matches VAULT_STARTUP_REGEX }
    it { is_expected.to wait_until_output_matches /upgrading keys finished/ }
    it { is_expected.to have_exposed_port tcp: 8200 }
  end

  describe 'accessing Vault with ruby API gem' do 
    it 'responds to the Vault gem' do 
      require 'vault'

      @vault = Vault::Client.new(
        ssl_verify: false,
        address: "http://127.0.0.1:#{@port}",
        ssl_timeout: 3,
        open_timeout: 3,
        read_timeout: 2,
        token: @root_token,
      )

      begin
        @vault.with_retries(Vault::HTTPConnectionError, attempts: 10) do
          @mounts = @vault.sys.mounts
        end
      rescue Vault::HTTPClientError => e
        raise "Error fetching Mounts: #{e}"
      end
    
      expect(@mounts).to include(:cubbyhole, :identity, :secret, :sys)

    end
  end

  after :all do
    if ENV["DEBUG"]
      puts "Debug Mode Enabled: Container was not stopped and killed"
      puts "Container ID: #{@container.id}"
    else  
      @container.kill signal: 'SIGKILL' unless @container.nil?
      @container.remove force: true, v: true unless @container.nil? 
    end
  end
end
