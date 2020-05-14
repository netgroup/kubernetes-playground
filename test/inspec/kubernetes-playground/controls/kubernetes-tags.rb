require 'yaml'

control "kubernetes" do
  title "kubernetes tags check"
  desc "This control checks that the kubernetes labels have been correctly applied"

    default_configuration = YAML.load_file('default.yaml')

    kubernetes_labels_configuration = default_configuration['kubernetes']['node_labels']

    kubernetes_labels_all_nodes = kubernetes_labels_configuration['all']
    kubernetes_labels_master_nodes = kubernetes_labels_configuration['masters']
    kubernetes_labels_worker_nodes = kubernetes_labels_configuration['workers']
    kubernetes_labels_by_node_name = kubernetes_labels_configuration['by_node_name']

    tag_configuration_type = [
        'all',
        'masters',
        'workers',
        'by_node_name'
    ]

    tag_configuration_type.each do |item|
        kubernetes_labels = kubernetes_labels_configuration[item]

        kubernetes_labels.each do |kubernetes_label|
            kubernetes_label_key = kubernetes_label['label_key']
            kubernetes_label_value = kubernetes_label['label_value']
            describe command('kubectl get nodes --short') do
                its('stdout') { should_not match /kubernetes_label_key=kubernetes_label_value/ }
            end
        end
    end
end
