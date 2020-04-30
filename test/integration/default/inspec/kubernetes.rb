require 'yaml'

control "kubernetes" do
  title "kubernetes role check"

  describe yum.repo('kubernetes') do
    it { should exist }
    it { should be_enabled }
    its('baseurl') { should include 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64' }
  end

  packages = [
    'conntrack-tools',
    'docker-ce',
    'glusterfs-cli',
    'kubeadm',
    'kubectl',
    'kubelet'
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

  if os.family == 'redhat'
    os_specific_vars_file_path = 'ansible/roles/kubernetes/vars/redhat.yml'
  end

  describe kernel_parameter('net.bridge.bridge-nf-call-iptables') do
    its('value') { should eq 1 }
  end

  describe kernel_parameter('net.bridge.bridge-nf-call-ip6tables') do
    its('value') { should eq 1 }
  end

  describe kernel_parameter('net.ipv4.ip_forward') do
    its('value') { should eq 1 }
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

    describe file(sysctl_configuration_file_path) do
        it { should exist }
        it { should be_file }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_readable.by_user('root') }
        its('mode') { should cmp '0644' }
    end

    describe etc_fstab.where { file_system_type.match(/swap/) } do
        it { should_not be_configured }
    end

  default_vars = YAML.load_file('ansible/roles/kubernetes/vars/main.yml')
  glusterfs_kernel_modules = default_vars['__ferrarimarco_kubernetes_glusterfs_kernel_modules']

  config = YAML.load_file('ansible/roles/kubernetes/defaults/main.yml')
  systemd_modules_load_path = config['ferrarimarco_kubernetes_kernel_modules_conf_dir']

  glusterfs_kernel_modules.each do |item|
    describe kernel_module(item) do
      it { should be_loaded }
      it { should_not be_disabled }
      it { should_not be_blacklisted }
    end

    describe file(File.join(systemd_modules_load_path, "#{item}.conf")) do
      it { should exist }
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_readable.by_user('root') }
      its('mode') { should cmp '0644' }
    end
  end

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
