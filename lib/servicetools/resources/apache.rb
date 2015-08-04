module Servicetools
  module Plugins
    class Apache < Resource

      include Systemd

      def initialize params = {}
        @pid_file = "#{@segment}/#{@customer}/#{@project}/logs/apache.pid"
        @conf_file = "#{@segment}/#{@customer}/#{@project}/conf/httpd.conf"
        @apache_bin = "/usr/bin/apachectl"

        params.each { |key, value| send "#{key}=", value }
      end

      def systemd_config
        {
          Unit: {
            Description: "Apache for #{@customer} #{@project}"
          },
          Service: {
            Type: 'forking',
            ExecStart: "#{@apache_bin} -f #{@conf_file} start",
            ExecStop: "#{@apache_bin} -f #{@conf_file} graceful-stop",
            ExecReload: "#{@apache_bin} -f #{@conf_file} graceful",
            PIDFile: @pid_file,
            PrivateTmp: 'true',
            LimitNOFILE: 'infinity'
          }
        }
      end
    end
  end
end
