
module Pure
  class BundledPlugin
    def initialize(project_name, plugin_name, empty_error)
      @project_name = project_name
      @plugin_name = plugin_name
      @empty_error = empty_error
    end

    def files
      result = Dir[File.dirname(__FILE__) + "/#{@plugin_name}/*.rb"].map {
        |file|
        file[%r!(#{@project_name}/#{@plugin_name}/.*)\.rb\Z!, 1]
      }
      result.sort  # rcov workaround
    end

    def fetch(file)
      begin
        require file
        [@project_name, @plugin_name, File.basename(file)].inject(Object) {
          |acc, name|
          acc.const_get(Util.to_camel_case(name))
        }
      rescue LoadError
        nil
      end
    end

    def available
      files.map { |file|
        [file, fetch(file)]
      }.reject { |file, object|
        object.nil?
      }.inject(Hash.new) { |acc, (file, object)|
        acc.merge!(file => object)
      }
    end
    
    def find_default
      files.each { |file|
        if found = fetch(file)
          return found
        end
      }
      raise @empty_error
    end
  end
end
