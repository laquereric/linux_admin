module LinuxAdmin
  class FileOperations
    extend Logging

    # Copy files or directories
    # @param source [String] Source file or directory path
    # @param destination [String] Destination file or directory path
    # @param options [Hash] Options for the copy operation
    # @option options [Boolean] :recursive Copy directories recursively
    # @option options [Boolean] :preserve Preserve file attributes
    # @option options [Boolean] :force Force overwrite existing files
    def self.copy(source, destination, options = {})
      raise ArgumentError, "source is required" unless source
      raise ArgumentError, "destination is required" unless destination

      params = {}
      params["-r"] = nil if options[:recursive]
      params["-p"] = nil if options[:preserve]
      params["-f"] = nil if options[:force]
      params[nil] = [source, destination]

      Common.run!(Common.cmd(:cp), :params => params)
    end

    # Move or rename files or directories
    # @param source [String] Source file or directory path
    # @param destination [String] Destination file or directory path
    # @param options [Hash] Options for the move operation
    # @option options [Boolean] :force Force overwrite existing files
    def self.move(source, destination, options = {})
      raise ArgumentError, "source is required" unless source
      raise ArgumentError, "destination is required" unless destination

      params = {}
      params["-f"] = nil if options[:force]
      params[nil] = [source, destination]

      Common.run!(Common.cmd(:mv), :params => params)
    end

    # Change file or directory permissions
    # @param mode [String, Integer] Permission mode (e.g., "755", 0755, "u+x")
    # @param target [String, Array] File or directory path(s)
    # @param options [Hash] Options for the chmod operation
    # @option options [Boolean] :recursive Apply changes recursively
    def self.chmod(mode, target, options = {})
      raise ArgumentError, "mode is required" unless mode
      raise ArgumentError, "target is required" unless target

      params = {}
      params["-R"] = nil if options[:recursive]
      params[nil] = [mode.to_s, target].flatten

      Common.run!(Common.cmd(:chmod), :params => params)
    end

    # Change file or directory ownership
    # @param owner [String] New owner (user or user:group)
    # @param target [String, Array] File or directory path(s)
    # @param options [Hash] Options for the chown operation
    # @option options [Boolean] :recursive Apply changes recursively
    def self.chown(owner, target, options = {})
      raise ArgumentError, "owner is required" unless owner
      raise ArgumentError, "target is required" unless target

      params = {}
      params["-R"] = nil if options[:recursive]
      params[nil] = [owner, target].flatten

      Common.run!(Common.cmd(:chown), :params => params)
    end

    # Create directories
    # @param path [String, Array] Directory path(s) to create
    # @param options [Hash] Options for the mkdir operation
    # @option options [Boolean] :parents Create parent directories as needed
    # @option options [String] :mode Set directory permissions
    def self.mkdir(path, options = {})
      raise ArgumentError, "path is required" unless path

      params = {}
      params["-p"] = nil if options[:parents]
      params["-m"] = options[:mode] if options[:mode]
      params[nil] = [path].flatten

      Common.run!(Common.cmd(:mkdir), :params => params)
    end

    # Check if a command exists in the system PATH
    # @param command [String] Command name to check
    # @return [Boolean] True if command exists, false otherwise
    def self.command_exists?(command)
      Common.cmd?(command)
    end

    # Get the full path to a command
    # @param command [String] Command name
    # @return [String, nil] Full path to command or nil if not found
    def self.command_path(command)
      Common.cmd(command)
    end
  end
end
