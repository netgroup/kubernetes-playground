# frozen_string_literal: true
require "yaml"

control "kubernetes-cluster-node" do
    title "kubernetes cluster node check"
    desc "This control checks that the the target is a valid Kubernetes cluster node"

    describe service("kubelet") do
        it { should be_installed }
        it { should be_enabled }
    end

    all_group_vars = YAML.load_file("ansible/group_vars/all.yaml")
    ip_to_host_mappings = all_group_vars["ip_to_host_mappings"]

    ip_to_host_mappings.each { |ip_to_host_mapping|
        ip_v4_address = ip_to_host_mapping["ip_v4_address"]
        ip_v6_address = ip_to_host_mapping["ipv6_address"]
        hostname = ip_to_host_mapping["hostname"]

        describe host(hostname) do
            it { should be_resolvable }
            its("ipaddress") { should include ip_v4_address }
            its("ipaddress") { should include ip_v6_address }
        end
    }
end
