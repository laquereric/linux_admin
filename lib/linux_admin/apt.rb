module LinuxAdmin
  class Apt < Package
    extend Logging

    APT_GET_CMD = '/usr/bin/apt-get'
    APT_CMD = '/usr/bin/apt'

    # Update package lists
    # @param options [Hash] Options for the update operation
    def self.update(options = {})
      logger.info("#{self.class.name}##{__method__} Updating package lists")
      
      params = {}
      params["-y"] = nil if options[:assume_yes]
      params["-q"] = nil if options[:quiet]
      
      Common.run!(APT_GET_CMD, :params => params.merge({"update" => nil}))
    end

    # Install packages
    # @param packages [String, Array] Package name(s) to install
    # @param options [Hash] Options for the install operation
    # @option options [Boolean] :assume_yes Assume yes to all prompts
    # @option options [Boolean] :quiet Quiet mode
    # @option options [Boolean] :fix_broken Fix broken dependencies
    def self.install(packages, options = {})
      raise ArgumentError, "packages are required" unless packages
      
      logger.info("#{self.class.name}##{__method__} Installing packages: #{packages}")
      
      params = {}
      params["-y"] = nil if options[:assume_yes]
      params["-q"] = nil if options[:quiet]
      params["-f"] = nil if options[:fix_broken]
      params[nil] = [packages].flatten
      
      Common.run!(APT_GET_CMD, :params => params.merge({"install" => nil}))
    end

    # Remove packages
    # @param packages [String, Array] Package name(s) to remove
    # @param options [Hash] Options for the remove operation
    # @option options [Boolean] :assume_yes Assume yes to all prompts
    # @option options [Boolean] :quiet Quiet mode
    # @option options [Boolean] :purge Remove configuration files as well
    def self.remove(packages, options = {})
      raise ArgumentError, "packages are required" unless packages
      
      logger.info("#{self.class.name}##{__method__} Removing packages: #{packages}")
      
      params = {}
      params["-y"] = nil if options[:assume_yes]
      params["-q"] = nil if options[:quiet]
      params["--purge"] = nil if options[:purge]
      params[nil] = [packages].flatten
      
      command = options[:purge] ? "purge" : "remove"
      Common.run!(APT_GET_CMD, :params => params.merge({command => nil}))
    end

    # Upgrade all packages
    # @param options [Hash] Options for the upgrade operation
    # @option options [Boolean] :assume_yes Assume yes to all prompts
    # @option options [Boolean] :quiet Quiet mode
    # @option options [Boolean] :dist_upgrade Perform distribution upgrade
    def self.upgrade(options = {})
      logger.info("#{self.class.name}##{__method__} Upgrading packages")
      
      params = {}
      params["-y"] = nil if options[:assume_yes]
      params["-q"] = nil if options[:quiet]
      
      command = options[:dist_upgrade] ? "dist-upgrade" : "upgrade"
      Common.run!(APT_GET_CMD, :params => params.merge({command => nil}))
    end

    # Search for packages
    # @param pattern [String] Search pattern
    # @param options [Hash] Options for the search operation
    def self.search(pattern, options = {})
      raise ArgumentError, "pattern is required" unless pattern
      
      logger.info("#{self.class.name}##{__method__} Searching for: #{pattern}")
      
      params = {}
      params[nil] = [pattern]
      
      Common.run!(APT_CMD, :params => params.merge({"search" => nil}))
    end

    # Show package information
    # @param package [String] Package name
    # @param options [Hash] Options for the show operation
    def self.show(package, options = {})
      raise ArgumentError, "package is required" unless package
      
      logger.info("#{self.class.name}##{__method__} Showing info for: #{package}")
      
      params = {}
      params[nil] = [package]
      
      Common.run!(APT_CMD, :params => params.merge({"show" => nil}))
    end

    # List installed packages
    # @param options [Hash] Options for the list operation
    # @option options [String] :pattern Filter by pattern
    def self.list_installed(options = {})
      logger.info("#{self.class.name}##{__method__} Listing installed packages")
      
      params = {}
      params["--installed"] = nil
      params[nil] = [options[:pattern]] if options[:pattern]
      
      result = Common.run!(APT_CMD, :params => params.merge({"list" => nil}))
      parse_package_list(result.output)
    end

    # Check for available updates
    # @param options [Hash] Options for the list operation
    def self.list_upgradable(options = {})
      logger.info("#{self.class.name}##{__method__} Listing upgradable packages")
      
      params = {}
      params["--upgradable"] = nil
      
      result = Common.run!(APT_CMD, :params => params.merge({"list" => nil}))
      parse_package_list(result.output)
    end

    # Clean package cache
    # @param options [Hash] Options for the clean operation
    # @option options [Boolean] :autoclean Remove only obsolete packages
    def self.clean(options = {})
      logger.info("#{self.class.name}##{__method__} Cleaning package cache")
      
      params = {}
      command = options[:autoclean] ? "autoclean" : "clean"
      
      Common.run!(APT_GET_CMD, :params => params.merge({command => nil}))
    end

    # Check if updates are available
    # @return [Boolean] True if updates are available
    def self.updates_available?
      result = list_upgradable
      !result.empty?
    end

    private

    # Parse package list output
    # @param output [String] Raw output from apt list command
    # @return [Array] Array of package information hashes
    def self.parse_package_list(output)
      packages = []
      output.split("\n").each do |line|
        next if line.empty? || line.start_with?("WARNING:")
        
        # Parse format: package/version architecture [status] description
        if match = line.match(/^(\S+)\/(\S+)\s+(\S+)\s+\[([^\]]+)\]\s+(.*)$/)
          packages << {
            :name => match[1],
            :version => match[2],
            :architecture => match[3],
            :status => match[4],
            :description => match[5]
          }
        end
      end
      packages
    end
  end
end
