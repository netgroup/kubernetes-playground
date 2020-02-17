require 'yaml'

control "docker" do
  title "docker role check"

  describe command('which docker') do
    its('exit_status') { should eq 0 }
  end

  config = YAML.load_file('ansible/roles/docker/defaults/main.yml')
  docker_compose_version = config['docker_compose_version']

  describe command('/usr/local/bin/docker-compose --version') do
    its('stdout') { should match(docker_compose_version) }
  end
end
