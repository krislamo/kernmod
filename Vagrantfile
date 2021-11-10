Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"
  config.vm.synced_folder ".", "/vagrant"
  config.vm.network "private_network", type: "dhcp"
  config.vm.provision "shell", path: "build.sh"
end
