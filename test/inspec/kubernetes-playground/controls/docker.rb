require 'yaml'

control "docker" do
  title "docker role check"
  desc "This control checks that the docker role has been correctly applied"

  describe command('which docker') do
    its('exit_status') { should eq 0 }
  end
end
