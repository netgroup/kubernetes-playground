require 'yaml'
require 'ipaddr'

# Load default settings
settings = YAML::load_file("defaults.yaml")

# Eventually customize the environment
env_specific_config_path = "env.yaml"
if File.exist?(env_specific_config_path)
  env_settings = YAML::load_file(env_specific_config_path)
  if !env_settings.nil?
    settings = settings.merge(env_settings)
  end
end

DEBUG_OUTPUT = settings["conf"]["debug_output"]

NETWORK_PREFIX = settings["net"]["network_prefix"]
NETWORK_PREFIX_IPV6 = settings["net"]["network_prefix_ipv6"]
SUBNET_MASK = settings["net"]["subnet_mask"]
SUBNET_MASK_IPV6 = settings["net"]["subnet_mask_ipv6"]

KUBEADM_TOKEN = "0y5van.5qxccw2ewiarl68v"
KUBERNETES_MASTER_1_IP = NETWORK_PREFIX + "10"
KUBERNETES_MASTER_1_IPV6 = NETWORK_PREFIX_IPV6 + settings["net"]["master_ipv6_part"]
KUBERNETES_MINION_1_IPV6 = NETWORK_PREFIX_IPV6 + settings["net"]["minion_1_ipv6_part"]
KUBERNETES_MINION_2_IPV6 = NETWORK_PREFIX_IPV6 + settings["net"]["minion_2_ipv6_part"]
KUBERNETES_MINION_3_IPV6 = NETWORK_PREFIX_IPV6 + settings["net"]["minion_3_ipv6_part"]

IF_NAME_FOR_FLANNEL = settings["net"]["if_name_for_flannel"]

PLAYGROUND_NAME = settings["conf"]["playground_name"]
DOMAIN = "." + PLAYGROUND_NAME + ".local"

DOCKER_REGISTRY_ALIAS = "registry" + DOMAIN
NETWORK_TYPE_DHCP = "dhcp"
NETWORK_TYPE_STATIC_IP = "static_ip"
WILDCARD_DOMAIN = "*" + DOMAIN

IP_V4_CIDR = IPAddr.new(SUBNET_MASK).to_i.to_s(2).count("1")
n = IPAddr.new("#{KUBERNETES_MASTER_1_IP}/#{IP_V4_CIDR}")
BROADCAST_ADDRESS = n | (~n.instance_variable_get(:@mask_addr) & IPAddr::IN4MASK)

# Cluster network
CLUSTER_IP_CIDR = settings["pod_network"]["cluster_ip_cidr"]
SERVICE_IP_CIDR = settings["pod_network"]["service_ip_cidr"]

# Vagrant boxes
VAGRANT_X64_KUBERNETES_NODES_BASE_BOX_ID = settings["conf"]["kubernetes_nodes_base_box_id"]
VAGRANT_X64_KUBERNETES_NODES_BOX_ID = "ferrarimarco/kubernetes-playground-node"
VAGRANT_X64_CONTROLLER_BOX_ID = VAGRANT_X64_KUBERNETES_NODES_BOX_ID

# VM Names
BASE_BOX_BUILDER_VM_NAME = settings["conf"]["base_box_builder_name"]
ANSIBLE_CONTROLLER_VM_NAME = settings["conf"]["ansi_ctrl_name"]
KUBERNETES_MASTER_1_VM_NAME = settings["conf"]["master_name"]
KUBERNETES_MINION_1_VM_NAME = settings["conf"]["minion_1_name"]
KUBERNETES_MINION_2_VM_NAME = settings["conf"]["minion_2_name"]
KUBERNETES_MINION_3_VM_NAME = settings["conf"]["minion_3_name"]

# VM IDs
BASE_BOX_BUILDER_VM_ID = BASE_BOX_BUILDER_VM_NAME + DOMAIN
ANSIBLE_CONTROLLER_VM_ID = ANSIBLE_CONTROLLER_VM_NAME + DOMAIN
KUBERNETES_MASTER_1_VM_ID = KUBERNETES_MASTER_1_VM_NAME + DOMAIN
KUBERNETES_MINION_1_VM_ID = KUBERNETES_MINION_1_VM_NAME + DOMAIN
KUBERNETES_MINION_2_VM_ID = KUBERNETES_MINION_2_VM_NAME + DOMAIN
KUBERNETES_MINION_3_VM_ID = KUBERNETES_MINION_3_VM_NAME + DOMAIN

# memory for each host
BASE_BOX_BUILDER_MEM = settings["conf"]["base_box_builder_mem"]
MASTER_MEM = settings["conf"]["master_mem"]
MINION_MEM = settings["conf"]["minion_mem"]
ANSI_CTRL_MEM = settings["conf"]["ansi_ctrl_mem"]

playground = {
  BASE_BOX_BUILDER_VM_ID => {
    :autostart => false,
    :box => VAGRANT_X64_KUBERNETES_NODES_BASE_BOX_ID,
    :cpus => 2,
    :mem => BASE_BOX_BUILDER_MEM,
    :net_auto_config => true,
    :show_gui => false,
    :host_vars => {
      "assigned_hostname" => BASE_BOX_BUILDER_VM_ID
    }
  },
  KUBERNETES_MASTER_1_VM_ID => {
    :alias => [DOCKER_REGISTRY_ALIAS],
    :autostart => true,
    :box => VAGRANT_X64_KUBERNETES_NODES_BOX_ID,
    :cpus => 2,
    :mac_address => "0800271F9D02",
    :mem => MASTER_MEM,
    :ip => KUBERNETES_MASTER_1_IP,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :subnet_mask_ipv6 => SUBNET_MASK_IPV6,
    :show_gui => false,
    :host_vars => {
      "ipv6_address" => KUBERNETES_MASTER_1_IPV6,
      "assigned_hostname" => KUBERNETES_MASTER_1_VM_ID
    }
  },
  KUBERNETES_MINION_1_VM_ID => {
    :autostart => true,
    :box => VAGRANT_X64_KUBERNETES_NODES_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D03",
    :mem => MINION_MEM,
    :ip => NETWORK_PREFIX + "30",
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :show_gui => false,
    :host_vars => {
      "ipv6_address" => KUBERNETES_MINION_1_IPV6,
      "assigned_hostname" => KUBERNETES_MINION_1_VM_ID
    }
  },
  KUBERNETES_MINION_2_VM_ID => {
    :autostart => true,
    :box => VAGRANT_X64_KUBERNETES_NODES_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D04",
    :mem => MINION_MEM,
    :ip => NETWORK_PREFIX + "31",
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :show_gui => false,
    :host_vars => {
      "ipv6_address" => KUBERNETES_MINION_2_IPV6,
      "assigned_hostname" => KUBERNETES_MINION_2_VM_ID
    }
  },
  KUBERNETES_MINION_3_VM_ID => {
    :autostart => true,
    :box => VAGRANT_X64_KUBERNETES_NODES_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D05",
    :mem => MINION_MEM,
    :ip => NETWORK_PREFIX + "32",
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :show_gui => false,
    :host_vars => {
      "ipv6_address" => KUBERNETES_MINION_3_IPV6,
      "assigned_hostname" => KUBERNETES_MINION_3_VM_ID
    }
  },
  ANSIBLE_CONTROLLER_VM_ID => {
    :autostart => true,
    :box => VAGRANT_X64_CONTROLLER_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D01",
    :mem => ANSI_CTRL_MEM,
    :ip => NETWORK_PREFIX + "9",
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :show_gui => false
  },
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
  host_var_path = "ansible/host_vars/#{info[:ip]}.yaml"
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
      BASE_BOX_BUILDER_VM_ID => nil
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
  "broadcast_address" => "#{BROADCAST_ADDRESS}",
  "docker_registry_host" => "#{DOCKER_REGISTRY_ALIAS}",
  "kubernetes_master_1_ip" => "#{KUBERNETES_MASTER_1_IP}",
  "kubeadm_token" => "#{KUBEADM_TOKEN}",
  "subnet_mask_ipv6" => "#{SUBNET_MASK_IPV6}",
  "wildcard_domain" => "#{WILDCARD_DOMAIN}",
  "playground_name" => "#{PLAYGROUND_NAME}",  
  "cluster_ip_cidr"  => "#{CLUSTER_IP_CIDR}",
  "service_ip_cidr"  => "#{SERVICE_IP_CIDR}",
  "if_name_for_flannel"  => "#{IF_NAME_FOR_FLANNEL}",
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

ADDITIONAL_DISK_SIZE = 10240

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

    # Find out folder of VM
    vm_folder = ""
    vm_info = driver.execute("showvminfo", uuid, "--machinereadable")
    lines = vm_info.split("\n")
    lines.each do |line|
      if line.start_with?("CfgFile")
        vm_folder = line.split("=")[1].gsub('"','')
        vm_folder = File.expand_path("..", vm_folder)
        ui.info "VM Folder is: #{vm_folder}"
      end
    end

    size = ADDITIONAL_DISK_SIZE
    name = env[:machine].provider_config.name
    disk_file = vm_folder + "/#{name}-disk-2.vmdk"

    ui.info "Adding disk to VM"
    if File.exist?(disk_file)
      ui.info "Disk already exists"
    else
      ui.info "Creating new disk"
      driver.execute("createmedium", "disk", "--filename", disk_file, "--size", "#{size}", "--format", "VMDK")
      ui.info "Attaching disk to VM"
      driver.execute('storageattach', uuid, '--storagectl', "SATA Controller", '--port', "1", '--type', 'hdd', '--medium', disk_file)
    end

    original_call(env)
  end
end

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  playground.each do |(hostname, info)|
    config.vm.define hostname, autostart: info[:autostart] do |host|
      host.vm.box = "#{info[:box]}"
      if(NETWORK_TYPE_DHCP == info[:net_type])
        host.vm.network :private_network, auto_config: info[:net_auto_config], :mac => "#{info[:mac_address]}", type: info[:net_type]
      elsif(NETWORK_TYPE_STATIC_IP == info[:net_type])
        host.vm.network :private_network, auto_config: info[:net_auto_config], :mac => "#{info[:mac_address]}", ip: "#{info[:ip]}", :netmask => "#{info[:subnet_mask]}"

        if(info.key?(:ipv6))
          host.vm.network :private_network, auto_config: info[:net_auto_config], :mac => "#{info[:mac_address_ipv6]}", ip: "#{info[:ipv6]}", :netmask => "#{info[:subnet_mask_ipv6]}"
        end
      end

      if info.key?(:alias)
        host.hostsupdater.aliases = info[:alias]
      end

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

      host.vm.hostname = hostname
      if(hostname.include? BASE_BOX_BUILDER_VM_NAME)
        host.vm.provision "shell" do |s|
          s.path = "scripts/linux/install-docker.sh"
          s.args = ["--user", "vagrant"]
        end

        host.vm.provision "shell", path: "scripts/linux/check-kubeadm-requirements.sh"
        host.vm.provision "shell" do |s|
          s.path = "scripts/linux/install-kubernetes.sh"
          s.args = ["--inventory", ansible_base_inventory_path, DEBUG_OUTPUT]
        end
      elsif(hostname.include?(ANSIBLE_CONTROLLER_VM_NAME))
        host.vm.provision "shell" do |s|
          s.path = "scripts/linux/install-kubernetes.sh"
          s.args = ["--inventory", ansible_inventory_path, DEBUG_OUTPUT]
        end
      else
        host.vm.provision "cleanup", type: "shell", run: "never" do |s|
          s.path = "scripts/linux/cleanup-k8s-and-cni.sh"
        end
      end
    end
  end
end
