require 'yaml'

control "docker" do
  title "docker role check"

  describe command('which docker') do
    its('exit_status') { should eq 0 }
  end
end
