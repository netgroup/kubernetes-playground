require 'yaml'

control "kubernetes" do
  title "kubernetes role check"
  desc "This control checks that the kubernetes role has been correctly applied"

    describe apt('https://apt.kubernetes.io/') do
        it { should exist }
        it { should be_enabled }
    end

  packages = [
    'docker-ce',
    'helm',
    'kubeadm',
    'kubectl',
    'kubelet',
    'python-selinux',
    'selinux-policy-default'
  ]

  packages.each do |item|
    describe package(item) do
      it { should be_installed }
    end
  end

  describe service('kubelet') do
    it { should be_installed }
    it { should be_enabled }
  end

    sysctl_parse_options = {
        assignment_regex: /^\s*([^=]*?)\s*=\s*(.*?)\s*$/
    }

    kernel_parameters = {
        'net.bridge.bridge-nf-call-iptables' => 1,
        'net.bridge.bridge-nf-call-ip6tables' => 1,
        'net.ipv4.ip_forward' => 1
    }

    sysctl_configuration_file_path = '/etc/sysctl.conf'

    kernel_parameters.each do |key,value|
        describe kernel_parameter(key) do
            its('value') { should eq value }
        end

        describe parse_config_file(sysctl_configuration_file_path, sysctl_parse_options).params[key] do
            it { should eq "#{value}" }
        end
    end

    describe etc_fstab.where { file_system_type.match(/swap/) } do
        it { should_not be_configured }
    end

  default_vars = YAML.load_file('ansible/roles/kubernetes/vars/main.yml')

    all_group_vars = YAML.load_file('ansible/group_vars/all.yaml')
    ip_to_host_mappings = all_group_vars['ip_to_host_mappings']

    ip_to_host_mappings.each { |ip_to_host_mapping|
        ip_v4_address = ip_to_host_mapping['ip_v4_address']
        hostname = ip_to_host_mapping['hostname']

        describe host(hostname) do
            it { should be_resolvable }
            its('ipaddress') { should include ip_v4_address }
        end
    }
end
