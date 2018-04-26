require 'yaml'

NETWORK_TYPE_DHCP = "dhcp"
NETWORK_TYPE_STATIC_IP = "static_ip"
SUBNET_MASK = "255.255.255.0"

# Vagrant boxes
VAGRANT_X64_CONTROLLER_BOX_ID = "bento/ubuntu-16.04"
VAGRANT_X64_KUBERNETES_NODES_BOX_ID = "bento/centos-7.4"

# VM Names
ANSIBLE_CONTROLLER_VM_NAME = "ansible-controller"

playground = {
  ANSIBLE_CONTROLLER_VM_NAME => {
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
  "kubernetes-master-1" => {
    :autostart => true,
    :box => VAGRANT_X64_KUBERNETES_NODES_BOX_ID,
    :cpus => 2,
    :mac_address => "0800271F9D02",
    :mem => 512,
    :ip => "192.168.0.10",
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :show_gui => false
  },
  "kubernetes-minion-1" => {
    :autostart => true,
    :box => VAGRANT_X64_KUBERNETES_NODES_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D03",
    :mem => 512,
    :ip => "192.168.0.30",
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :show_gui => false
  },
  "kubernetes-minion-2" => {
    :autostart => true,
    :box => VAGRANT_X64_KUBERNETES_NODES_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D04",
    :mem => 512,
    :ip => "192.168.0.31",
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :subnet_mask => SUBNET_MASK,
    :show_gui => false
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

group_vars = {
  "ansible_become_pass" => "vagrant",
  "ansible_become_user" => "vagrant",
  "ansible_ssh_pass" => "vagrant",
  "ansible_user" => "vagrant",
  "ansible_ssh_extra_args" => "-o StrictHostKeyChecking=no"
}
IO.write("ansible/group_vars/#{ansible_master_group_name}.yaml", group_vars.to_yaml)
IO.write("ansible/group_vars/#{ansible_minion_group_name}.yaml", group_vars.to_yaml)
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

      host.vm.provision "shell", path: "scripts/linux/check-kubeadm-requirements.sh"
    end
  end
end
