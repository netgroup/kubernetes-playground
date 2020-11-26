# frozen_string_literal: true
require "yaml"

control "kubernetes" do
  title "kubernetes role check"
  desc "This control checks that the kubernetes role has been correctly applied"

    describe apt("https://apt.kubernetes.io/") do
        it { should exist }
        it { should be_enabled }
    end

  packages = [
    "docker-ce",
    "kubeadm",
    "kubectl",
    "kubelet",
    "python-selinux",
    "selinux-policy-default",
    "snapd",
    "ipvsadm"
  ]

  packages.each do |item|
    describe package(item) do
      it { should be_installed }
    end
  end

  describe service("kubelet") do
    it { should be_installed }
    it { should be_enabled }
  end

    sysctl_parse_options = {
        assignment_regex: /^\s*([^=]*?)\s*=\s*(.*?)\s*$/
    }

    kernel_parameters = {
        "net.bridge.bridge-nf-call-iptables" => 1,
        "net.bridge.bridge-nf-call-ip6tables" => 1,
        "net.ipv4.ip_forward" => 1
    }

    sysctl_configuration_file_path = "/etc/sysctl.conf"

    kernel_parameters.each do |key, value|
        describe kernel_parameter(key) do
            its("value") { should eq value }
        end

        describe parse_config_file(sysctl_configuration_file_path, sysctl_parse_options).params[key] do
            it { should eq "#{value}" }
        end
    end

    describe etc_fstab.where { file_system_type.match(/swap/) } do
        it { should_not be_configured }
    end

  default_vars = YAML.load_file("ansible/roles/kubernetes/vars/main.yml")

end
