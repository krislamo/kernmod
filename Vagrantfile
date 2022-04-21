VAGRANT_BOX=ENV["VAGRANT_BOX"]
if !VAGRANT_BOX || VAGRANT_BOX == "debian"
  VAGRANT_BOX = "debian/bullseye64"
elsif VAGRANT_BOX == "rocky"
  VAGRANT_BOX = "rockylinux/8"
elsif VAGRANT_BOX == "centos"
  VAGRANT_BOX = "centos/7"
end

Vagrant.configure("2") do |config|
  config.vm.box = VAGRANT_BOX
  config.vm.synced_folder ".", "/vagrant"
  config.vm.network "private_network", type: "dhcp"
  config.vm.provision "shell", path: "build.sh"
end
