require 'yaml'
require 'ipaddr'

@ui = Vagrant::UI::Colored.new

# Load the required Vagrant version from the CI configuration.
# This forces us to be consistent with the CI environment.

# Load Travis CI configuration
travis_configuration_file_path = ".travis.yml"
travis_configuration = YAML::load_file(travis_configuration_file_path)

travis_global_environment_variables = travis_configuration["env"]["global"]

# If we used the array form, let's parse it and put the results in a hash for
# easy access. If we used the key-value format, no other processing is needed
if travis_global_environment_variables.kind_of?(Array)
    travis_global_environment_variables_hash = Hash.new
    travis_global_environment_variables.each{
        # x is the variable used to access the array item we're currently
        # iterating on.
        |x|

        # Split multiple variables, if any. The format is: VAR_1=VAL_1 VAR_2=VAL_2
        env_vars_item = x.strip.split(" ")
        env_vars_item.each{
            |y|
            # Split key from value
            env_variable = y.strip.split("=")

            # Note that if the same variable appears with different values, the last
            # value takes precedence.
            env_variable_key = env_variable[0]

            # Check if the variable is initialized, or just defined.
            # If the variable isn't initialized, set the value to nil, but include
            # the key in the hash, so at least you know the variable was defined.
            env_variable_value = (env_variable.length == 1 ? nil : env_variable[1])

            # Remove double quotes for easier parsing
            env_variable_key.gsub!('"', '')
            unless env_variable_key.nil?
                env_variable_value.gsub!('"', '')
            end

            # Shoot out a warning if we overwrite a variable value, so at least
            # the user knows what's happening. We might need a better way to handle this,
            # but then we also need to deal with multple values (define multiple VMs? multiple provisioners?).
            # Let's not complicate this now.
            if travis_global_environment_variables_hash.key?(env_variable_key)
                # Get the current value before we overwrite it
                current_environment_variable_value = travis_global_environment_variables_hash[env_variable_key]

                # Warn the user if the values is going to be overwritten
                if current_environment_variable_value != env_variable_value
                    @ui.warn "The #{env_variable_key} environment variable value is going to change from\n#{current_environment_variable_value} to #{env_variable_value} because you defined it\nmultiple times in #{travis_configuration_file_path}."
                end
            end

            # Finally, add the key-value pair to the hash
            travis_global_environment_variables_hash[env_variable_key] = env_variable_value
        }
    }

    # Let's not complicate things below. Reuse the same variable, so we don't have
    # to check which hash we're using every time.
    travis_global_environment_variables = travis_global_environment_variables_hash
end

# Require the minimum Vagrant version we currently support
required_vagrant_version = travis_global_environment_variables['VAGRANT_VERSION']
vagrant_version_constraint = ">= #{required_vagrant_version}"
Vagrant.require_version vagrant_version_constraint
@ui.info "The current Vagrant version satisfies the constraints: #{vagrant_version_constraint}"

# Proc settings merger
settings_merger = proc {
    |key, v_default, v_env|
    if Hash === v_default && Hash === v_env
        v_default.merge(v_env, &settings_merger)
    elsif [:undefined, nil, :nil].include?(v_env)
        v_default
    else
        v_env
    end
}

# Load default settings
settings = YAML::load_file("defaults.yaml")

# If needed customize the environment
env_specific_config_path = "env.yaml"
if File.exist?(env_specific_config_path)
  env_settings = YAML::load_file(env_specific_config_path)
  if !env_settings.nil?
    settings = settings.merge(env_settings, &settings_merger)
  end
end

# Check that an allowed networking plugin is provided
allowed_cni_plugins=["weavenet","calico","flannel","no-cni-plugin"]
if not allowed_cni_plugins.include? settings["ansible"]["group_vars"]["all"]["kubernetes_network_plugin"]
  @ui.error 'kubernetes_network_plugin is not valid in defaults.yaml or env.yaml, allowed values are:'
  allowed_cni_plugins.each {|valid| @ui.error valid }
  exit(1)
end

# Check that the provider is supported
allowed_vagrant_providers=[ "virtualbox", "libvirt"]
vagrant_provider = settings["conf"]["vagrant_provider"]
if not allowed_vagrant_providers.include? vagrant_provider
  @ui.error 'vagrant_provider is not valid in defaults.yaml or env.yaml, allowed values are:'
  allowed_vagrant_providers.each {|valid| @ui.error valid }
  exit(2)
end

libvirt_management_network_address = settings["net"]["libvirt_management_network_address"]
netmask=libvirt_management_network_address.split('/')
if netmask[1].to_i > 24
  @ui.error 'only netmasks <= 24 in libvirt_management_network_address are safely supported'
  exit(3)
end
ip_split=libvirt_management_network_address.split('.')
libvirt_management_host_address = ip_split[0]+'.'+ip_split[1]+'.'+ip_split[2]+'.1'

additional_ansible_arguments = settings["conf"]["additional_ansible_arguments"]

network_prefix = settings["net"]["network_prefix"]
network_prefix_ipv6 = settings["net"]["network_prefix_ipv6"]
subnet_mask = settings["net"]["subnet_mask"]
subnet_mask_ipv6 = settings["net"]["subnet_mask_ipv6"]

kubeadm_token = "0y5van.5qxccw2ewiarl68v"
kubernetes_master_1_ip = network_prefix + "10"
kubernetes_master_1_ipv6 = network_prefix_ipv6 + settings["net"]["master_ipv6_part"]
kubernetes_minion_1_ipv6 = network_prefix_ipv6 + settings["net"]["minion_1_ipv6_part"]
kubernetes_minion_2_ipv6 = network_prefix_ipv6 + settings["net"]["minion_2_ipv6_part"]
kubernetes_minion_3_ipv6 = network_prefix_ipv6 + settings["net"]["minion_3_ipv6_part"]

playground_name = settings["conf"]["playground_name"]
domain = "." + playground_name + ".local"

docker_registry_alias = "registry" + domain
network_type_dhcp = "dhcp"
network_type_static_ip = "static_ip"
wildcard_domain = "*" + domain

ip_v4_cidr = IPAddr.new(subnet_mask).to_i.to_s(2).count("1")
n = IPAddr.new("#{kubernetes_master_1_ip}/#{ip_v4_cidr}")
broadcast_address = n | (~n.instance_variable_get(:@mask_addr) & IPAddr::IN4MASK)

# Cluster network
cluster_ip_cidr = settings["pod_network"]["cluster_ip_cidr"]
service_ip_cidr = settings["pod_network"]["service_ip_cidr"]

# Vagrant boxes
vagrant_x64_kubernetes_nodes_base_box_id = settings["conf"]["kubernetes_nodes_base_box_id"][vagrant_provider]
vagrant_x64_kubernetes_nodes_box_id = "ferrarimarco/kubernetes-playground-node"

# VM Names
$base_box_builder_vm_name = settings["conf"]["base_box_builder_name"]
kubernetes_master_1_vm_name = settings["conf"]["master_name"]
kubernetes_minion_1_vm_name = settings["conf"]["minion_1_name"]
kubernetes_minion_2_vm_name = settings["conf"]["minion_2_name"]
kubernetes_minion_3_vm_name = settings["conf"]["minion_3_name"]

# Defines where to run the Ansible container during the provisioning phase.
# This must be the last machine to be created, because the other ones have to be
# available before attempting any provisioning.
ansible_controller_vm_name = kubernetes_minion_3_vm_name

# VM IDs
base_box_builder_vm_id = $base_box_builder_vm_name + domain
kubernetes_master_1_vm_id = kubernetes_master_1_vm_name + domain
kubernetes_minion_1_vm_id = kubernetes_minion_1_vm_name + domain
kubernetes_minion_2_vm_id = kubernetes_minion_2_vm_name + domain
kubernetes_minion_3_vm_id = kubernetes_minion_3_vm_name + domain

# memory for each host
base_box_builder_mem = settings["conf"]["base_box_builder_mem"]
master_mem = settings["conf"]["master_mem"]
minion_mem = settings["conf"]["minion_mem"]

$additional_disk_size = settings["conf"]["additional_disk_size"]

# path to the shared folder with the VMs
vagrant_root = File.dirname(__FILE__)

playground = {
  base_box_builder_vm_id => {
    :autostart => false,
    :box => vagrant_x64_kubernetes_nodes_base_box_id,
    :cpus => 2,
    :mem => base_box_builder_mem,
    :net_auto_config => true,
    :show_gui => false,
    :host_vars => {
      "base_box" => true,
      "assigned_hostname" => base_box_builder_vm_id
    }
  },
  kubernetes_master_1_vm_id => {
    :alias => [docker_registry_alias],
    :autostart => true,
    :box => vagrant_x64_kubernetes_nodes_box_id,
    :cpus => 2,
    :mac_address => "0800271F9D02",
    :mem => master_mem,
    :ip => kubernetes_master_1_ip,
    :net_auto_config => true,
    :net_type => network_type_static_ip,
    :subnet_mask => subnet_mask,
    :show_gui => false,
    :host_vars => {
      "ipv6_address" => kubernetes_master_1_ipv6,
      "assigned_hostname" => kubernetes_master_1_vm_id
    }
  },
  kubernetes_minion_1_vm_id => {
    :autostart => true,
    :box => vagrant_x64_kubernetes_nodes_box_id,
    :cpus => 1,
    :mac_address => "0800271F9D03",
    :mem => minion_mem,
    :ip => network_prefix + "30",
    :net_auto_config => true,
    :net_type => network_type_static_ip,
    :subnet_mask => subnet_mask,
    :show_gui => false,
    :host_vars => {
      "ipv6_address" => kubernetes_minion_1_ipv6,
      "assigned_hostname" => kubernetes_minion_1_vm_id
    }
  },
  kubernetes_minion_2_vm_id => {
    :autostart => true,
    :box => vagrant_x64_kubernetes_nodes_box_id,
    :cpus => 1,
    :mac_address => "0800271F9D04",
    :mem => minion_mem,
    :ip => network_prefix + "31",
    :net_auto_config => true,
    :net_type => network_type_static_ip,
    :subnet_mask => subnet_mask,
    :show_gui => false,
    :host_vars => {
      "ipv6_address" => kubernetes_minion_2_ipv6,
      "assigned_hostname" => kubernetes_minion_2_vm_id
    }
  },
  kubernetes_minion_3_vm_id => {
    :autostart => true,
    :box => vagrant_x64_kubernetes_nodes_box_id,
    :cpus => 1,
    :mac_address => "0800271F9D05",
    :mem => minion_mem,
    :ip => network_prefix + "32",
    :net_auto_config => true,
    :net_type => network_type_static_ip,
    :subnet_mask => subnet_mask,
    :show_gui => false,
    :host_vars => {
      "ipv6_address" => kubernetes_minion_3_ipv6,
      "assigned_hostname" => kubernetes_minion_3_vm_id
    }
  }
}

# Generate an inventory file

masters = {}
minions = {}
playground.each do |(hostname, info)|
  if(hostname.include? "master")
    masters[info[:ip]] = nil
  elsif(hostname.include? "minion")
    minions[info[:ip]] = nil
  end
  if info.key?(:ip)
    host_var_filename = "#{info[:ip]}"
  else
    host_var_filename = "#{hostname}"
  end
  host_var_path = "ansible/host_vars/#{host_var_filename}.yaml"
  if info.key?(:host_vars)
    IO.write(host_var_path, info[:host_vars].to_yaml)
  else
    if File.exist?(host_var_path)
      File.delete(host_var_path)
    end
  end
end
ansible_master_group_name = "kubernetes-masters"
ansible_minion_group_name = "kubernetes-minions"
ansible_inventory_path = "ansible/hosts"
ansible_base_inventory_path = "ansible/hosts-base"

inventory_base = {
  "all" => {
    "hosts" => {
      base_box_builder_vm_id => nil
    }
  }
}

IO.write(ansible_base_inventory_path, inventory_base.to_yaml)

inventory = {
  "all" => {
    "children" => {
      ansible_master_group_name => {
        "hosts" => masters
      },
      ansible_minion_group_name => {
        "hosts" => minions
      },
    }
  }
}

IO.write(ansible_inventory_path, inventory.to_yaml)

default_group_vars = {
  "ansible_ssh_extra_args" => "-o StrictHostKeyChecking=no",
  "ansible_ssh_pass" => "vagrant",
  "ansible_user" => "vagrant",
  "broadcast_address" => "#{broadcast_address}",
  "docker_registry_host" => "#{docker_registry_alias}",
  "kubernetes_master_1_ip" => "#{kubernetes_master_1_ip}",
  "kubeadm_token" => "#{kubeadm_token}",
  "subnet_mask_ipv6" => "#{subnet_mask_ipv6}",
  "wildcard_domain" => "#{wildcard_domain}",
  "playground_name" => "#{playground_name}",
  "cluster_ip_cidr"  => "#{cluster_ip_cidr}",
  "service_ip_cidr"  => "#{service_ip_cidr}",
}
custom_all_group_vars = settings["ansible"]["group_vars"]["all"]
if !custom_all_group_vars.nil?
  default_group_vars = default_group_vars.merge(custom_all_group_vars)
end
IO.write("ansible/group_vars/all.yaml", default_group_vars.to_yaml)

master_group_vars = {
  "kubernetes_classifier" => "master"
}
custom_master_group_vars = settings["ansible"]["group_vars"]["#{ansible_master_group_name}"]
if !custom_master_group_vars.nil?
  master_group_vars = master_group_vars.merge(custom_master_group_vars)
end
IO.write("ansible/group_vars/#{ansible_master_group_name}.yaml", master_group_vars.to_yaml)

minion_group_vars = {
  "kubernetes_classifier" => "minion"
}
custom_minion_group_vars = settings["ansible"]["group_vars"]["#{ansible_minion_group_name}"]
if !custom_minion_group_vars.nil?
  minion_group_vars = minion_group_vars.merge(custom_minion_group_vars)
end
IO.write("ansible/group_vars/#{ansible_minion_group_name}.yaml", minion_group_vars.to_yaml)

# Workaround for https://github.com/hashicorp/vagrant/issues/8878
class VagrantPlugins::ProviderVirtualBox::Action::Network
  def dhcp_server_matches_config?(dhcp_server, config)
    true
  end
end

# Let's extend the SetName class
# to attach a second disk
class VagrantPlugins::ProviderVirtualBox::Action::SetName
  alias_method :original_call, :call
  def call(env)
    machine = env[:machine]
    driver = machine.provider.driver
    uuid = driver.instance_eval { @uuid }
    ui = env[:ui]

    vm_name = env[:machine].provider_config.name

    unless(vm_name.include? $base_box_builder_vm_name)
        ui.info "Finding out in which directory the #{vm_name} VM was created on the host."
        vm_folder = ""
        vm_info = driver.execute("showvminfo", uuid, "--machinereadable")
        lines = vm_info.split("\n")
        lines.each do |line|
            if line.start_with?("CfgFile")
                vm_folder = line.split("=")[1].gsub('"','')
                vm_folder = File.expand_path("..", vm_folder)
                ui.info "The #{vm_name} VM is in the #{vm_folder} directory on the host."
            end
        end

        size = $additional_disk_size

        if size > 0
            disk_file = vm_folder + "/#{vm_name}-disk-2.vmdk"

            ui.info "Adding a disk of #{size} MB to the #{vm_name} VM. Disk file path: #{disk_file}."
            if File.exist?(disk_file)
            ui.info "A disk file already exists in #{disk_file}."
            else
            ui.info "Creating a new disk file in #{disk_file}."
            driver.execute("createmedium", "disk", "--filename", disk_file, "--size", "#{size}", "--format", "VMDK")
            ui.info "Attaching the #{disk_file} disk to the #{vm_name} VM."
            driver.execute('storageattach', uuid, '--storagectl', "SATA Controller", '--port', "1", '--type', 'hdd', '--medium', disk_file)
            end
        else
            ui.info "Not attaching any disk, because the disk size is set to #{size}"
        end
    end

    original_call(env)
  end
end

# Let's extend the Destroy class
# to delete the second disk
class VagrantPlugins::ProviderVirtualBox::Action::Destroy
  alias_method :original_call, :call
  def call(env)
    machine = env[:machine]
    driver = machine.provider.driver
    uuid = driver.instance_eval { @uuid }
    ui = env[:ui]

    vm_name = env[:machine].provider_config.name

    ui.info "Finding out in which directory the #{vm_name} VM was created on the host."
    vm_folder = ""
    vm_info = driver.execute("showvminfo", uuid, "--machinereadable")
    lines = vm_info.split("\n")
    lines.each do |line|
        if line.start_with?("CfgFile")
            vm_folder = line.split("=")[1].gsub('"','')
            vm_folder = File.expand_path("..", vm_folder)
            ui.info "The #{vm_name} VM is in the #{vm_folder} directory on the host."
        end
    end

    ui.info "Deleting all VMDK files in #{vm_folder}"
    Dir.glob("#{vm_folder}/*").select{ |file| /.vmdk/.match file }.each { |file| File.delete(file)}

    original_call(env)
  end
end

Vagrant.configure("2") do |config|

  # Install the required Vagrant plugins.
  # Populate this hash with the plugins that don't depend on specific provisioners or providers.
  config.vagrant.plugins = {
    "vagrant-hostsupdater" => {"version" => "1.1.1"}
  }

  playground.each do |(hostname, info)|
    config.vm.define hostname, autostart: info[:autostart] do |host|
      host.vm.box = "#{info[:box]}"
      if(network_type_dhcp == info[:net_type])
        host.vm.network :private_network, auto_config: info[:net_auto_config], :mac => "#{info[:mac_address]}", type: info[:net_type]
      elsif(network_type_static_ip == info[:net_type])
        host.vm.network :private_network, auto_config: info[:net_auto_config], :mac => "#{info[:mac_address]}", ip: "#{info[:ip]}", :netmask => "#{info[:subnet_mask]}"
      end

      if info.key?(:alias)
        host.hostsupdater.aliases = info[:alias]
      end

      if(vagrant_provider == 'virtualbox')
        host.vm.provider :virtualbox do |vb|
          vb.customize ["modifyvm", :id, "--cpus", info[:cpus]]
          vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
          vb.customize ["modifyvm", :id, "--memory", info[:mem]]
          vb.customize ["modifyvm", :id, "--name", hostname]
          vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
          vb.customize ["modifyvm", :id, "--natdnshostresolver2", "on"]
          vb.gui = info[:show_gui]
          vb.name = hostname
        end
      elsif(vagrant_provider == 'libvirt')
        host.vm.provider :libvirt do |libvirt|
          libvirt.cpus = info[:cpus]
          libvirt.memory = info[:mem]
          libvirt.nested = true
          libvirt.default_prefix = ''
          libvirt.management_network_address = libvirt_management_network_address
        end
      end
      host.vm.hostname = hostname
      if(hostname.include? $base_box_builder_vm_name)
        host.vm.provision "shell" do |s|
          s.path = "scripts/linux/install-docker.sh"
          s.args = ["--user", "vagrant"]
        end

        config.ssh.insert_key = false

        # Ensure password authentication is enabled.
        # We might have to resort to a more secure solution in the future, but
        # for now it's enough.
        host.vm.provision "shell", path: "scripts/linux/enable-ssh-password-authentication.sh"

        host.vm.provision "shell", path: "scripts/linux/check-kubeadm-requirements.sh"
        host.vm.provision "shell" do |s|
          s.path = "scripts/linux/install-kubernetes.sh"
          s.args = ["--inventory", ansible_base_inventory_path, "--additional-ansible-arguments", additional_ansible_arguments]
        end
      else
        if(hostname.include?(ansible_controller_vm_name))
          host.vm.provision "shell" do |s|
            s.path = "scripts/linux/install-kubernetes.sh"
            s.args = ["--inventory", ansible_inventory_path, "--additional-ansible-arguments", additional_ansible_arguments]
          end

          host.vm.provision "quick-setup", type: "shell", run: "never" do |s|
            s.path = "scripts/linux/install-kubernetes.sh"
            s.args = ["--inventory", ansible_inventory_path, "--additional-ansible-arguments", additional_ansible_arguments, "--quick-setup" ]
          end
        end
        host.vm.provision "cleanup", type: "shell", run: "never" do |s|
          s.path = "scripts/linux/cleanup-k8s-and-cni.sh"
        end
        $mountNfsShare = ''
        if(vagrant_provider == 'virtualbox')
            $mountNfsShare = <<-'SCRIPT'
            # From now on, we want the script to fail if we have problems mounting the shares
            set -e
            if ! mount | grep -qs /vagrant ; then
                mount -t vboxsf vagrant /vagrant/
            fi
            SCRIPT
        elsif(vagrant_provider == 'libvirt')
            # Vagrant plugins for the libvirt provider
            config.vagrant.plugins.merge!({
                "vagrant-libvirt" => {"version" => "0.0.45"}
            })

            $mountNfsShare = <<-'SCRIPT'
            # From now on, we want the script to fail if we have problems mounting the shares
            set -e
            if ! mount | grep -qs /vagrant ; then
                mount -t nfs -o 'vers=3' $libvirt_management_host_address:$vagrant_root /vagrant
            fi
            SCRIPT
            $mountNfsShare.gsub!("$libvirt_management_host_address", libvirt_management_host_address)
            $mountNfsShare.gsub!("$vagrant_root", vagrant_root)
        end
        host.vm.provision "mount-shared", type: "shell", run: "never", inline: $mountNfsShare
      end
    end
  end
end
