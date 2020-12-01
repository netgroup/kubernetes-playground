# frozen_string_literal: true

require "yaml"
require "ipaddr"

@ui = Vagrant::UI::Colored.new

# Definition of constants
MAX_NUMBER_OF_MASTER_NODES ||= 1
ERR_NET_PLUGIN_CONF ||= 1
ERR_PROVIDER_CONF ||= 2
ERR_LIBVIRT_MGT_NET_CONF ||= 3
ERR_CALICO_ENV_VAR_CONF ||= 4
ERR_CALICO_ENV_VAR_VALUE_CONF ||= 5
ERR_BAD_IPV6_SUFFIX ||= 6
ERR_MASTER_NODE_COUNT ||= 7


def log_info_or_debug(message)
  if ENV["VAGRANT_LOG"]=="debug" or ENV["VAGRANT_LOG"]=="info"
    @ui.info message
  end
end

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
    travis_global_environment_variables.each {
        # x is the variable used to access the array item we're currently
        # iterating on.
        |x|

        # Split multiple variables, if any. The format is: VAR_1=VAL_1 VAR_2=VAL_2
        env_vars_item = x.strip.split(" ")
        env_vars_item.each {
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
            env_variable_key.gsub!('"', "")
            unless env_variable_key.nil?
                env_variable_value.gsub!('"', "")
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
required_vagrant_version = travis_global_environment_variables["VAGRANT_VERSION"]
vagrant_version_constraint = ">= #{required_vagrant_version}"
Vagrant.require_version vagrant_version_constraint
log_info_or_debug "The current Vagrant version satisfies the constraints: #{vagrant_version_constraint}"


# Proc settings merger
settings_merger = proc {
    |key, v_default, v_env|
    if v_default.is_a?(Hash) && v_env.is_a?(Hash)
        v_default.merge(v_env, &settings_merger)
    elsif [:undefined, nil, :nil].include?(v_env)
        v_default
    else
        v_env
    end
}

# set a 'target_key' in settings, parsing a dictionary of options 'selected_dict'
# extracted from the .yaml
# 'option_array' is the list of all the possible options
# if there is a problem in the .yaml the Vagrantfile exits
# with 'error' as error code
# see for example 'kubernetes_network_plugin_options' dictionary in defaults.yaml,
# used to set the key 'kubernetes_network_plugin' in settings
def check_and_select_conf_options(selected_dict, target_key, option_array, error)
  counter=0
  return_value = ""
  option_array.each do |choice|
    if selected_dict[target_key+"_options"][choice]
      counter = counter + 1
      return_value = choice
    end
  end
  if counter == 1
    selected_dict[target_key]=return_value
    return return_value
  else
    @ui.error "select exactly one option in defaults.yaml/env.yaml, allowed options:"
    option_array.each { |valid| @ui.error valid }
    @ui.error "current selection: " + selected_dict.to_s
    exit(error)
  end
end

# returns the string representation of the IPv6 address to be used
# for a node
def get_ipv6_address(base_addr, base_suffix, order, delta, final_part)
  output = base_addr
  suffix_num = Integer("0x" + base_suffix[0, 4])
  if base_suffix[4, 2] != "::"
    @ui.error "Malformed IPv6 suffix (must be a string with 4 hex digits followed by \"::\")"
    @ui.error "Value: " + base_suffix
    exit(ERR_BAD_IPV6_SUFFIX)
  end
  suffix_num = suffix_num + order * delta
  output = output + "%04x" % suffix_num + "::" + final_part
  return output
end

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

# Display the main current configuration parameters
log_info_or_debug "Welcome to Kubernetes playground!"
log_info_or_debug "Vagrant provider: #{settings["conf"]["vagrant_provider"]}"
log_info_or_debug "Active settings (from defaults.yaml and env.yaml): #{settings.to_yaml}"

# Check that at least one and only one plugin is selected
check_and_select_conf_options(settings["ansible"]["group_vars"]["all"],
                              "kubernetes_network_plugin",
                              ["no-cni-plugin", "weavenet", "calico", "flannel"],
                              ERR_NET_PLUGIN_CONF)
log_info_or_debug "Networking plugin: #{settings["ansible"]["group_vars"]["all"]["kubernetes_network_plugin"]}"
# if calico, check that at least one and only one env_var and env_var_value is selected
if settings["ansible"]["group_vars"]["all"]["kubernetes_network_plugin"] == "calico"
  check_and_select_conf_options(settings["ansible"]["group_vars"]["all"]["calico_config"],
                              "calico_env_var",
                              ["CALICO_IPV4POOL_IPIP", "CALICO_IPV4POOL_VXLAN"],
                              ERR_CALICO_ENV_VAR_CONF)
  check_and_select_conf_options(settings["ansible"]["group_vars"]["all"]["calico_config"],
                              "calico_env_var_value",
                              ["Always", "CrossSubnet", "Never"],
                              ERR_CALICO_ENV_VAR_VALUE_CONF)
  log_info_or_debug "Calico environment variable: #{settings["ansible"]["group_vars"]["all"]["calico_config"]["calico_env_var"]} = #{settings["ansible"]["group_vars"]["all"]["calico_config"]["calico_env_var_value"]}"
end

# Check that the provider is supported
allowed_vagrant_providers=["virtualbox", "libvirt"]
vagrant_provider = settings["conf"]["vagrant_provider"]
if !allowed_vagrant_providers.include? vagrant_provider
  @ui.error "vagrant_provider is not valid in defaults.yaml or env.yaml, allowed values are:"
  allowed_vagrant_providers.each { |valid| @ui.error valid }
  exit(ERR_PROVIDER_CONF)
end

libvirt_management_network_address = settings["net"]["libvirt_management_network_address"]
netmask=libvirt_management_network_address.split("/")
if netmask[1].to_i > 24
  @ui.error "only netmasks <= 24 in libvirt_management_network_address are safely supported"
  exit(ERR_LIBVIRT_MGT_NET_CONF)
end
ip_split=libvirt_management_network_address.split(".")
libvirt_management_host_address = ip_split[0] + "." + ip_split[1] + "." + ip_split[2] + ".1"

additional_ansible_arguments = settings["conf"]["additional_ansible_arguments"]

network_prefix = settings["net"]["network_prefix"]
network_prefix_ipv6 = settings["net"]["network_prefix_ipv6"]
node_suffix_ipv6 = settings["net"]["minion_ipv6_part"]
default_ipv6_host_part = settings["net"]["default_ipv6_host_part"]
delta_ipv6 = settings["net"]["delta_ipv6"]
subnet_mask = settings["net"]["subnet_mask"]
subnet_mask_ipv6 = settings["net"]["subnet_mask_ipv6"]
master_ipv4_base = settings["net"]["master_ipv4_base"]
minion_ipv4_base = settings["net"]["minion_ipv4_base"]

master_base_mac_address = settings["net"]["master_base_mac_address"]
minion_base_mac_address = settings["net"]["minion_base_mac_address"]

kubeadm_token = "0y5van.5qxccw2ewiarl68v"
kubernetes_master_1_ip = network_prefix + master_ipv4_base.to_s
kubernetes_master_1_ipv6 = network_prefix_ipv6 + settings["net"]["master_ipv6_part"]+ settings["net"]["default_ipv6_host_part"]

playground_name = settings["conf"]["playground_name"]
domain = "." + playground_name + ".local"

docker_registry_alias = "registry" + domain
network_type_dhcp = "dhcp"
network_type_static_ip = "static_ip"
wildcard_domain = "*" + domain
assigned_hostname_key = "assigned_hostname"

ip_v4_cidr = IPAddr.new(subnet_mask).to_i.to_s(2).count("1")
n = IPAddr.new("#{kubernetes_master_1_ip}/#{ip_v4_cidr}")
broadcast_address = n | (~n.instance_variable_get(:@mask_addr) & IPAddr::IN4MASK)

# Cluster network
cluster_ip_cidr = settings["pod_network"]["cluster_ip_cidr"]
cluster_ipv6_cidr = settings["pod_network"]["cluster_ipv6_cidr"]
service_ip_cidr = settings["pod_network"]["service_ip_cidr"]

calico_env_var = settings["ansible"]["group_vars"]["all"]["calico_config"]["calico_env_var"]
calico_env_var_value = settings["ansible"]["group_vars"]["all"]["calico_config"]["calico_env_var_value"]

# Vagrant boxes
vagrant_x64_kubernetes_nodes_base_box_id = settings["conf"]["kubernetes_nodes_base_box_id"][vagrant_provider]
vagrant_x64_kubernetes_nodes_box_id = "ferrarimarco/kubernetes-playground-node"

# VM Names
$base_box_builder_vm_name = settings["conf"]["base_box_builder_name"]
kubernetes_master_1_vm_name = settings["conf"]["master_name"]

# VM IDs
base_box_builder_vm_id = $base_box_builder_vm_name + domain
kubernetes_master_1_vm_id = kubernetes_master_1_vm_name + domain

# memory for each host
base_box_builder_mem = settings["conf"]["base_box_builder_mem"]
master_mem = settings["conf"]["master_mem"]
minion_mem = settings["conf"]["minion_mem"]

additional_disk_size = settings["conf"]["additional_disk_size"]

allow_workloads_on_masters = settings["kubernetes"]["allow_workloads_on_masters"]

# path to the shared folder with the VMs
vagrant_root = File.dirname(__FILE__)

kubernetes_master_nodes_count=settings["kubernetes"]["master_nodes_count"]
if kubernetes_master_nodes_count > MAX_NUMBER_OF_MASTER_NODES
  @ui.error "The maximum number of master nodes is " + MAX_NUMBER_OF_MASTER_NODES.to_s
  exit(ERR_MASTER_NODE_COUNT)
end

kubernetes_worker_nodes_count = settings["kubernetes"]["worker_nodes_count"]
kubernetes_worker_nodes = {}

ansible_controller_vm_name = nil

kubernetes_worker_nodes_count.times { |i|
    # Count from 1, to maintain the same behaviour of the static configuration
    node_name = "k8s-minion-#{i + 1}"
    node_id = node_name + domain
    node_ipv4_address = network_prefix + (minion_ipv4_base+i).to_s
    node_ipv6_address = get_ipv6_address(network_prefix_ipv6, node_suffix_ipv6, i, delta_ipv6, default_ipv6_host_part)
    node_mac_address = minion_base_mac_address[0, 10] + "%02x" % (Integer("0x" + minion_base_mac_address[10, 2]) + i)
    kubernetes_worker_nodes[node_id] = {
        autostart: true,
        box: vagrant_x64_kubernetes_nodes_box_id,
        cpus: 1,
        mac_address: node_mac_address,
        mem: minion_mem,
        ip: node_ipv4_address,
        net_auto_config: true,
        net_type: network_type_static_ip,
        subnet_mask: subnet_mask,
        show_gui: false,
        host_vars: {
            "ipv4_address": node_ipv4_address,
            "ipv6_address": node_ipv6_address,
            assigned_hostname_key: node_id
        }
    }

    # Defines where to run the Ansible container during the provisioning phase.
    # This must be the last machine to be created, because the other ones have to be
    # available before attempting any provisioning.
    # Assign it on every loop round, so at the end of the loop it will be assigned
    # to the last worker node to be added to the pool.
    ansible_controller_vm_name = node_name
}

playground = {
  base_box_builder_vm_id => {
    autostart: false,
    box: vagrant_x64_kubernetes_nodes_base_box_id,
    cpus: 2,
    mem: base_box_builder_mem,
    net_auto_config: true,
    show_gui: false,
    host_vars: {
      "base_box": true,
      assigned_hostname_key: base_box_builder_vm_id
    }
  },
  kubernetes_master_1_vm_id => {
    alias: [docker_registry_alias],
    autostart: true,
    box: vagrant_x64_kubernetes_nodes_box_id,
    cpus: 2,
    mac_address: master_base_mac_address,
    mem: master_mem,
    ip: kubernetes_master_1_ip,
    net_auto_config: true,
    net_type: network_type_static_ip,
    subnet_mask: subnet_mask,
    show_gui: false,
    host_vars: {
      "ipv4_address": kubernetes_master_1_ip,
      "ipv6_address": kubernetes_master_1_ipv6,
      assigned_hostname_key: kubernetes_master_1_vm_id
    }
  },
}

playground.merge!(kubernetes_worker_nodes)

# Generate an inventory file

masters = {}
minions = {}
ip_to_host_mappings = []
playground.each do |(hostname, info)|
  if(hostname.include? "master")
    masters[hostname] = nil
  elsif(hostname.include? "minion")
    minions[hostname] = nil
  end

  if info.key?(:ip)
    ip_to_host_mappings.push(
        "ip_v4_address" => "#{info[:ip]}",
        "hostname" => "#{hostname}"
    )
  end

  host_var_filename = "#{hostname}"
  host_var_path = "ansible/host_vars/#{host_var_filename}.yaml"
  if info.key?(:host_vars)
    IO.write(host_var_path, info[:host_vars].to_yaml)
  else
    if File.exist?(host_var_path)
      File.delete(host_var_path)
    end
  end
end

# Add the docker registry host alias
ip_to_host_mappings.push(
    "ip_v4_address" => "#{kubernetes_master_1_ip}",
    "hostname" => "#{docker_registry_alias}"
)

hosts_file_entries=""

ip_to_host_mappings.each do |(ip_to_host_mapping)|
    hosts_file_entries += "#{ip_to_host_mapping['hostname']},#{ip_to_host_mapping["ip_v4_address"]};"
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
  "allow_workloads_on_masters" => "#{allow_workloads_on_masters}",
  "ansible_ssh_extra_args" => "-o StrictHostKeyChecking=no",
  "ansible_ssh_pass" => "vagrant",
  "ansible_user" => "vagrant",
  "broadcast_address" => "#{broadcast_address}",
  "docker_registry_host" => "#{docker_registry_alias}",
  "kubernetes_master_1_hostname" => "#{kubernetes_master_1_vm_id}",
  "kubernetes_master_1_ip" => "#{kubernetes_master_1_ip}",
  "kubeadm_token" => "#{kubeadm_token}",
  "subnet_mask_ipv6" => "#{subnet_mask_ipv6}",
  "wildcard_domain" => "#{wildcard_domain}",
  "playground_name" => "#{playground_name}",
  "cluster_ip_cidr"  => "#{cluster_ip_cidr}",
  "cluster_ipv6_cidr"  => "#{cluster_ipv6_cidr}",
  "service_ip_cidr"  => "#{service_ip_cidr}",
  "calico_env_var"  => "#{calico_env_var}",
  "calico_env_var_value"  => "#{calico_env_var_value}",
  "ip_to_host_mappings" => ip_to_host_mappings
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

def get_virtualbox_default_machine_directory
    log_info_or_debug "Getting the default Virtualbox machine directory..."

    # Create an instance of the Virtualbox driver, so we can reuse Vagrant's logic
    virtualbox_driver = VagrantPlugins::ProviderVirtualBox::Driver::Version_6_1.new("")
    virtualbox_default_machine_directory = virtualbox_driver.read_machine_folder

    # If we're in WSL, the path must me adapted to be something meaningful in WSL,
    # because VBoxManage returns a Windows path (it runs in Windows, so it's right!).
    # Then we convert it to a path in "ruby format" (which is always with /, regardless of the platform)
    if Vagrant::Util::Platform.wsl?
        virtualbox_default_machine_directory_wsl = `wslpath -a -u "#{virtualbox_default_machine_directory}"`.gsub('\n', "")
        virtualbox_default_machine_directory_wsl_m = `wslpath -a -m "#{virtualbox_default_machine_directory_wsl}"`.gsub('\n', "")
        virtualbox_default_machine_directory = virtualbox_default_machine_directory_wsl_m
    end
    log_info_or_debug "The default Virtualbox machine directory is #{virtualbox_default_machine_directory}"
    return virtualbox_default_machine_directory
end

Vagrant.configure("2") do |config|

  # Install the required Vagrant plugins.
  # Populate this hash with the plugins that don't depend on specific provisioners or providers.
  config.vagrant.plugins = {}

  playground.each do |(hostname, info)|
    config.vm.define hostname, autostart: info[:autostart] do |host|
      host.vm.box = "#{info[:box]}"
      if(network_type_dhcp == info[:net_type])
        host.vm.network :private_network, auto_config: info[:net_auto_config], mac: "#{info[:mac_address]}", type: info[:net_type]
      elsif(network_type_static_ip == info[:net_type])
        host.vm.network :private_network, auto_config: info[:net_auto_config], mac: "#{info[:mac_address]}", ip: "#{info[:ip]}", netmask: "#{info[:subnet_mask]}"
      end

      if(vagrant_provider == "virtualbox")
        host.vm.provider :virtualbox do |vb|
          virtualbox_default_machine_directory = get_virtualbox_default_machine_directory

          log_info_or_debug "Getting the directory where the #{hostname} VM files are..."
          vm_directory = File.join(virtualbox_default_machine_directory, hostname)
          log_info_or_debug "The #{hostname} VM is in the #{vm_directory} directory on the host."

          vb.customize ["modifyvm", :id, "--cpus", info[:cpus]]
          vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
          vb.customize ["modifyvm", :id, "--memory", info[:mem]]
          vb.customize ["modifyvm", :id, "--name", hostname]

          if (additional_disk_size > 0 && (minions.has_key? hostname))
            disk_file = vm_directory + "/#{hostname}-disk-2.vmdk"
            log_info_or_debug "Adding a disk of #{additional_disk_size} MB to the #{hostname} VM. Disk file path: #{disk_file}."
            if File.exist?(disk_file)
              log_info_or_debug "A disk file already exists in #{disk_file}."
            else
              log_info_or_debug "Creating a new disk file in #{disk_file}."
              vb.customize ["createmedium", "disk", "--filename", disk_file, "--size", additional_disk_size, "--format", "VMDK"]
              log_info_or_debug "Attaching the #{disk_file} disk to the #{hostname} VM."
              vb.customize ["storageattach", hostname, "--storagectl", "SATA Controller", "--port", "1", "--type", "hdd", "--medium", disk_file]
            end
          else
            log_info_or_debug "Not attaching any disk, because the disk size is set to #{additional_disk_size}"
          end

          host.trigger.after :destroy do |trigger|
            trigger.name = "Delete VMDK files in #{vm_directory}"
            trigger.ruby do |env, machine|
              log_info_or_debug "Deleting all VMDK files in #{vm_directory}"
              Dir.glob("#{vm_directory}/*").select { |file| /.vmdk/.match file }.each { |file| File.delete(file) }
            end
          end

          vb.gui = info[:show_gui]
          vb.name = hostname
        end
      elsif(vagrant_provider == "libvirt")
        host.vm.provider :libvirt do |libvirt|
          libvirt.cpus = info[:cpus]
          libvirt.memory = info[:mem]
          libvirt.nested = true
          libvirt.default_prefix = ""
          libvirt.management_network_address = libvirt_management_network_address

          if(additional_disk_size > 0 && (!hostname.include? $base_box_builder_vm_name))
              libvirt.storage :file,
                size: additional_disk_size,
                path: hostname + "_sdb.img",
                device: "sdb"
          end

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

        host.vm.provision "shell" do |s|
          s.path = "scripts/linux/install-kubernetes.sh"
          s.args = ["--inventory", ansible_base_inventory_path, "--additional-ansible-arguments", additional_ansible_arguments]
        end
      else
        if(hostname.include?(ansible_controller_vm_name))
          host.vm.provision "shell" do |s|
            s.path = "scripts/linux/update-hosts.sh"
            s.args = ["#{hosts_file_entries}"]
          end

        host.vm.provision "shell" do |s|
          s.path = "scripts/linux/install-kubernetes.sh"
          s.args = ["--inventory", ansible_inventory_path, "--additional-ansible-arguments", additional_ansible_arguments]
        end

          host.vm.provision "quick-setup", type: "shell", run: "never" do |s|
            s.path = "scripts/linux/install-kubernetes.sh"
            s.args = ["--inventory", ansible_inventory_path, "--additional-ansible-arguments", additional_ansible_arguments, "--quick-setup"]
          end
        end
        host.vm.provision "cleanup", type: "shell", run: "never" do |s|
          s.path = "scripts/linux/cleanup-k8s-and-cni.sh"
        end
        $mountNfsShare = ""
        if(vagrant_provider == "virtualbox")
            $mountNfsShare = <<-'SCRIPT'
            # From now on, we want the script to fail if we have problems mounting the shares
            set -e
            if ! mount | grep -qs /vagrant ; then
                mount -t vboxsf vagrant /vagrant/
            fi
            SCRIPT
        elsif(vagrant_provider == "libvirt")
            # Vagrant plugins for the libvirt provider
            # When updating this, ensure that the versions you specify here match
            # with scripts/linux/ci/install-vagrant-plugins.sh
            config.vagrant.plugins["vagrant-libvirt"] = {"version" => "0.1.2"}

            $mountNfsShare = <<-"SCRIPT"
            # From now on, we want the script to fail if we have problems mounting the shares
            set -e
            if ! mount | grep -qs /vagrant ; then
                mount -t nfs -o 'vers=3' $libvirt_management_host_address:$vagrant_root /vagrant
            fi
            SCRIPT
            $mountNfsShare = $mountNfsShare.gsub("$libvirt_management_host_address", libvirt_management_host_address)
            $mountNfsShare = $mountNfsShare.gsub("$vagrant_root", vagrant_root)
        end
        host.vm.provision "mount-shared", type: "shell", run: "never", inline: $mountNfsShare
      end
        host.vm.provision "diagnostics", type: "shell", run: "never" do |s|
            s.path = "scripts/linux/ci/diagnostics.sh"
            s.args = ["--host"]
        end
    end
  end
end
