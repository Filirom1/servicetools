module Servicetools
  class Resource
    attr_accessor :name, :plugin_name, :args, :dispatcher, :user, :log_files

    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
    end
  end
end
