module Servicetools
  class Project
    attr_accessor :segment, :customer, :name, :resources

    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
    end

    def action(name, options)
      @resources.send name.to_sym, options
    end
  end
end
