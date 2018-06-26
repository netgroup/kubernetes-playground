require 'yaml'
require 'ipaddr'

KUBEADM_TOKEN = "0y5van.5qxccw2ewiarl68v"
KUBERNETES_MASTER_1_IP = "192.168.0.10"

DOMAIN = ".kubernetes-playground.local"
DOCKER_REGISTRY_ALIAS = "registry" + DOMAIN
NETWORK_TYPE_DHCP = "dhcp"
NETWORK_TYPE_STATIC_IP = "static_ip"
SUBNET_MASK = "255.255.255.0"
WILDCARD_DOMAIN = "*" + DOMAIN

IP_V4_CIDR = IPAddr.new(SUBNET_MASK).to_i.to_s(2).count("1")
n = IPAddr.new("#{KUBERNETES_MASTER_1_IP}/#{IP_V4_CIDR}")
BROADCAST_ADDRESS = n | (~n.instance_variable_get(:@mask_addr) & IPAddr::IN4MASK)

# Vagrant boxes
VAGRANT_X64_CONTROLLER_BOX_ID = "bento/ubuntu-16.04"
VAGRANT_X64_KUBERNETES_NODES_BOX_ID = "bento/centos-7.4"

# VM Names
ANSIBLE_CONTROLLER_VM_NAME = "ansible-controller"
KUBERNETES_MASTER_1_VM_NAME = "kubernetes-master-1"

playground = {
  KUBERNETES_MASTER_1_VM_NAME + DOMAIN => {
    :alias => [DOCKER_REGISTRY_ALIAS],
    :autostart => true,
    :box => VAGRANT_X64_KUBERNETES_NODES_BOX_ID,
    :cpus => 2,
    :mac_address => "0800271F9D02",
    :mem => 4096,
    :ip => KUBERNETES_MASTER_1_IP,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :show_gui => false
  },
  "kubernetes-minion-1" + DOMAIN => {
    :autostart => true,
    :box => VAGRANT_X64_KUBERNETES_NODES_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D03",
    :mem => 2048,
    :ip => "192.168.0.30",
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :show_gui => false
  },
  "kubernetes-minion-2" + DOMAIN => {
    :autostart => true,
    :box => VAGRANT_X64_KUBERNETES_NODES_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D04",
    :mem => 2048,
    :ip => "192.168.0.31",
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :show_gui => false
  },
  "kubernetes-minion-3" + DOMAIN => {
    :autostart => true,
    :box => VAGRANT_X64_KUBERNETES_NODES_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D05",
    :mem => 2048,
    :ip => "192.168.0.32",
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :show_gui => false
  },
  ANSIBLE_CONTROLLER_VM_NAME + DOMAIN => {
    :autostart => true,
    :box => VAGRANT_X64_CONTROLLER_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D01",
    :mem => 512,
    :ip => "192.168.0.2",
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
IO.write("ansible/hosts", inventory.to_yaml)

default_group_vars = {
  "ansible_ssh_extra_args" => "-o StrictHostKeyChecking=no",
  "ansible_ssh_pass" => "vagrant",
  "ansible_user" => "vagrant",
  "broadcast_address" => "#{BROADCAST_ADDRESS}",
  "docker_registry_host" => "#{DOCKER_REGISTRY_ALIAS}",
  "kubernetes_master_1_ip" => "#{KUBERNETES_MASTER_1_IP}",
  "kubeadm_token" => "#{KUBEADM_TOKEN}",
  "wildcard_domain" => "#{WILDCARD_DOMAIN}"
}
IO.write("ansible/group_vars/all.yaml", default_group_vars.to_yaml)

master_group_vars = {
  "kubernetes_classifier" => "master"
}
IO.write("ansible/group_vars/#{ansible_master_group_name}.yaml", master_group_vars.to_yaml)

minion_group_vars = {
  "kubernetes_classifier" => "minion"
}
IO.write("ansible/group_vars/#{ansible_minion_group_name}.yaml", minion_group_vars.to_yaml)

ADDITIONAL_DISK_SIZE = 10240

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
      end

      if info.key?(:alias)
        host.hostsupdater.aliases = info[:alias]
      end

      host.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        vb.customize ["modifyvm", :id, "--cpus", info[:cpus]]
        vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
        vb.customize ["modifyvm", :id, "--memory", info[:mem]]
        vb.customize ["modifyvm", :id, "--name", hostname]
        vb.gui = info[:show_gui]
        vb.name = hostname
      end

      host.vm.hostname = hostname

      if(hostname.include? ANSIBLE_CONTROLLER_VM_NAME)
        host.vm.provision "shell" do |s|
          s.path = "scripts/linux/install-docker.sh"
          s.args = [
            "--user", "vagrant"
            ]
        end
      end

      if(!hostname.include? ANSIBLE_CONTROLLER_VM_NAME)
        host.vm.provision "shell", path: "scripts/linux/check-kubeadm-requirements.sh"
      end

      # Install Kubernetes on masters and minions
      if(hostname.include? ANSIBLE_CONTROLLER_VM_NAME)
        host.vm.provision "shell", path: "scripts/linux/install-kubernetes.sh"
      end
    end
  end
end
