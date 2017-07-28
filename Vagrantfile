Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.2"
  config.vm.provision "shell", path: "mariadb_setup.sh", run: "always"
end
