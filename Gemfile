# frozen_string_literal: true
source "https://rubygems.org"

if Gem::Version.new(Bundler::VERSION) < Gem::Version.new('1.13.0')
  abort "Bundler version >= 1.13.0 is required"
end

gem "inspec", '4.18.108'
gem "kitchen-ansible", '0.50.1'
gem "kitchen-inspec", '1.3.2'
gem "kitchen-vagrant", '1.6.1'
gem "rake", '13.0.1'
gem "test-kitchen", '2.4.0'
# Cannot fix travis version because some of its deps have conflicts with other deps
gem "travis"
