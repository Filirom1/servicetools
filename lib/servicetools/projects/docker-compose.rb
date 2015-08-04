module Servicetools
  module Plugins
    class DockerComposeProject < Project
      def initialize
        @compose_bin = "/usr/local/bin/docker-compose"
        @main = DockerComposeMainResource.new(to_hash)
      end

      def action(name, options)
        @main.send name.to_sym, options
        resources = generate_container_resources

        resources.each do |resource|
          resource.send name.to_sym, options
        end
      end

      def generate_container_resources
        resources  = []
        Dir.chdir "#{@segment}/#{@customer}/docker-compose/conf/"
        lines = `#{@compose_bin} -p #{@name} -f production.yml ps`.split("\n")
        lines.each do |line|
          name = line.split(/\s+/)[0]
          resources << ContainerResource.new(name: name)
        end
      end
    end

    class DockerComposeMainResource < Resource
      include Systemd

      def initialize(params = {})
        @resource_dir = "#{@segment}/#{@customer}/#{@project}"
        @pid_file = "#{@resource_dir}/logs/compose.pid"
        @conf_file = "#{@resource_dir}/conf/production.yml"
        @compose_bin = "/usr/local/bin/docker-compose"
      end

      def systemd_config
        {
          Unit: {
            Description: "Docker Compose for #{@customer} #{@project}"
          },
          Service: {
            Type: 'simple',
            ExecStart: "#{@compose_bin} -p #{@project} -f #{@conf_file} up",
            ExecStartPost: "#{@resource_dir}/conf/post-up",
            ExecStop: "#{@compose_bin} -p #{@project} -f #{@conf_file} stop",
            ExecReload: "#{@compose_bin} -p #{@project} -f #{@conf_file} restart",
            PIDFile: @pid_file,
          }
        }
      end
    end

    class ContainerResource < Resource
      def start(options)
        return true if options.all_resources
        system "docker start #{@name}"
      end

      def stop(options)
        return true if options.all_resources
        system "docker stop #{@name}"
      end

      def restart(options)
        return true if options.all_resources
        system "docker restart #{@name}"
      end

      def info(options)
      end

      def status(options)
        `docker inspect -f {{.State.Running}} #{@name}` == 'true'
      end
    end
  end
end
