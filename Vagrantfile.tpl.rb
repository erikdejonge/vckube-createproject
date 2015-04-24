# -*- mode: ruby -*-
# # vi: set ft=ruby :
require 'fileutils'
require 'open-uri'
require 'yaml'
# noinspection RubyResolve
Vagrant.require_version '>= 1.6.0'
$cloud_config_path = ''
# Defaults for config options defined in CONFIG
$num_instances = x
$update_channel = 'beta'
$enable_serial_logging = false
$share_home = false
$vm_gui = x
$vm_memory = x
$vm_cpus = x
$etcdaddress = nil
# Attempt to apply the deprecated environment variable NUM_INSTANCES to
# $num_instances while allowing config.rb to override it
if ENV['NUM_INSTANCES'].to_i > 0 && ENV['NUM_INSTANCES']
  $num_instances = ENV['NUM_INSTANCES'].to_i
end
# Use old vb_xxx config variables when set
def vm_gui
  # noinspection RubyResolve
  $vb_gui.nil? ? $vm_gui : $vb_gui
end
def vm_memory
  # noinspection RubyResolve
  $vb_memory.nil? ? $vm_memory : $vb_memory
end
def vm_cpus
  # noinspection RubyResolve
  $vb_cpus.nil? ? $vm_cpus : $vb_cpus
end
# noinspection RubyResolve
Vagrant.configure('2') do |config|
  # noinspection RubyResolve
  config.ssh.insert_key = false
  # noinspection RubyResolve
  config.ssh.private_key_path = ['keys/insecure/vagrant']
  # noinspection RubyResolve
  config.vm.box = 'coreos-%s' % $update_channel
  # noinspection RubyResolve
  config.vm.box_version = '>= 308.0.1'
  # noinspection RubyResolve
  config.vm.box_url = 'http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json' % $update_channel
  # noinspection RubyLiteralArrayInspection
  ['vmware_fusion', 'vmware_workstation'].each do |vmware|
    # noinspection RubyResolve
    config.vm.provider vmware do |_, override|
      # noinspection RubyResolve
      override.vm.box_url = 'http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json' % $update_channel
    end
  end
  # noinspection RubyResolve
  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    # noinspection RubyResolve
    v.check_guest_additions = false
    # noinspection RubyResolve
    v.functional_vboxsf = false
  end
  # plugin conflict
  # noinspection RubyResolve
  if Vagrant.has_plugin?('vagrant-vbguest')
    # noinspection RubyResolve
    config.vbguest.auto_update = false
  end
  (1..$num_instances).each do |i|
    basehostname = open('config/basehostname.txt').read
    basehostname = basehostname.strip
    basehostname = basehostname+ '%1d' % i
    config.vm.define vm_name = basehostname do |configvm|
      # noinspection RubyResolve
      configvm.vm.hostname = vm_name+'.a8.nl'
      #if $expose_docker_tcp
      #    configvm.vm.network 'forwarded_port', guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
      #end
      logdir = File.join(File.dirname(__FILE__), 'logs')
      FileUtils.mkdir_p(logdir)
      serial_file = File.join(logdir, '%s-serial.txt' % vm_name)
      FileUtils.touch(serial_file)
      # noinspection RubyLiteralArrayInspection
      ['vmware_fusion', 'vmware_workstation'].each do |vmware|
        # noinspection RubyResolve
        configvm.vm.provider vmware do |v|
          # noinspection RubyResolve
          v.gui = vm_gui
          # noinspection RubyResolve
          v.vmx['memsize'] = vm_memory
          v.vmx['numvcpus'] = vm_cpus
          v.vmx['serial0.present'] = 'TRUE'
          v.vmx['serial0.fileType'] = 'file'
          v.vmx['serial0.fileName'] = serial_file
          v.vmx['serial0.tryNoRxLoss'] = 'FALSE'
        end
      end
      # noinspection RubyResolve
      configvm.vm.provider :virtualbox do |vb|
        # noinspection RubyResolve
        vb.gui = vm_gui
        # noinspection RubyResolve
        vb.memory = vm_memory
        # noinspection RubyResolve
        vb.cpus = vm_cpus
      end
      startip = open('config/startip.txt').read
      startip = startip.strip
      pubipaddress = startip + '%1d' % i
      if $etcdaddress==nil
        $etcdaddress = pubipaddress
      end
      # noinspection RubyResolve
      configvm.vm.network :public_network, ip:pubipaddress
      if ARGV[0].eql?('up')
        $cloud_config_path = File.join(File.dirname(__FILE__), 'configscripts/user-data%1d' % i)
        $cloud_config_path += '.yml'
        privipaddress = '127.0.0.1'
        updategroup = open('config/updatetoken.txt').read
        updategroup = updategroup.strip
        if i==1
          # noinspection RubyResolve
          data = YAML.load(IO.readlines('configscripts/master.yml')[1..-1].join)
        else
          # noinspection RubyResolve
          data = YAML.load(IO.readlines('configscripts/node.yml')[1..-1].join)
        end
        data['coreos']['update']['group'] = updategroup
        token = open('config/token.txt').read
        token = token.strip
        data['coreos']['etcd2']['discovery'] = token
        gateway = open('config/gateway.txt').read
        environ = 'COREOS_PUBLIC_IPV4='+pubipaddress+"\nCOREOS_PRIVATE_IPV4="+privipaddress
        envvars = open('config/envvars.sh').read
        envvars = envvars.strip + "\n"
        envvars += "export ETCDCTL_PEERS='http://"+$etcdaddress+":2379'\n"
        envvars += "export FLEETCTL_ENDPOINT='http://"+$etcdaddress+":2379'\n"
        envvars += "export DEFAULT_IPV4='"+pubipaddress+"'\n\n"
        data['write_files'][0]['content'] = "[Match]\nName=ens34\n\n[Network]\nAddress="+pubipaddress+"/24\nGateway="+gateway+"\nDNS=8.8.8.8\nDNS=8.8.4.4\n\n"
        data['write_files'][1]['content'] = environ
        data['write_files'][2]['content'] = envvars
        data['hostname'] = configvm.vm.hostname
        yaml = YAML.dump(data)
        yaml = yaml.gsub("\\{", '{')
        yaml = yaml.gsub("<public-ip>", pubipaddress)
        puts $cloud_config_path
        File.open($cloud_config_path, 'w') { |file| file.write("#cloud-config\n\n#{yaml}\n\n") }
      end
      if File.exist?($cloud_config_path)
        # noinspection RubyResolve
        configvm.vm.provision :file, :source => "#{$cloud_config_path}", :destination => '/tmp/vagrantfile-user-data'
        # noinspection RubyResolve
        configvm.vm.provision :shell, :inline => 'mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/vagrantfile-user-data', :privileged => true
        # noinspection RubyResolve
        configvm.vm.provision :shell, :inline => 'halt -p', :privileged => true
      end
    end
  end
end