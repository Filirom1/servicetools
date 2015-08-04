module Servicetools
  class Systemd
    def start(options)
      generate_service
      system "systemctl start #{@project}"
    end
    
    def stop(options)
      generate_service
      system "systemctl stop #{@project}"
    end
    
    def status(options)
      generate_service
      system "systemctl status #{@project}"
    end

    def restart(options)
      generate_service
      system "systemctl restart #{@project}"
    end

    def info(options)
    end

    def systemd_config(options)
      raise "to be implemented"
    end

    def generate_service
    end
  end
end
