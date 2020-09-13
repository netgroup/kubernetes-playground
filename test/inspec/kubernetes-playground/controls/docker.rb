require "yaml"

control "docker" do
  title "docker role check"
  desc "This control checks that the docker role has been correctly applied"

    describe apt("https://download.docker.com/linux/debian") do
        it { should exist }
        it { should be_enabled }
    end

    packages = [
        "apt-transport-https",
        "ca-certificates",
        "curl",
        "gnupg-agent",
        "docker-ce",
        "software-properties-common",
    ]

    packages.each do |item|
        describe package(item) do
            it { should be_installed }
        end
    end

    describe service("docker") do
        it { should be_installed }
        it { should be_enabled }
        it { should be_running }
    end

    describe group("docker") do
        it { should exist }
    end

    describe command("docker") do
        it { should exist }
    end
end
