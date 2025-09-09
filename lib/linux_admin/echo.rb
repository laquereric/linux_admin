module LinuxAdmin
  class Echo
    extend Logging

    ECHO_CMD = '/bin/echo'

    # Output text to stdout
    # @param text [String] Text to output
    # @param options [Hash] Options for the echo operation
    # @option options [Boolean] :no_newline Do not output a trailing newline
    # @option options [Boolean] :interpret_backslash Interpret backslash escapes
    # @option options [String] :output_file Write output to file instead of stdout
    def self.output(text, options = {})
      raise ArgumentError, "text is required" unless text

      logger.info("#{self.class.name}##{__method__} Outputting text")

      params = {}
      params["-n"] = nil if options[:no_newline]
      params["-e"] = nil if options[:interpret_backslash]
      params[nil] = [text]

      if options[:output_file]
        # Use shell redirection for file output
        cmd = "#{ECHO_CMD} #{params_to_string(params)} > #{options[:output_file]}"
        Common.run!(cmd)
      else
        Common.run!(ECHO_CMD, :params => params)
      end
    end

    # Write text to a file
    # @param text [String] Text to write
    # @param file_path [String] File path to write to
    # @param options [Hash] Options for the write operation
    # @option options [Boolean] :append Append to file instead of overwriting
    # @option options [Boolean] :no_newline Do not add trailing newline
    def self.write_to_file(text, file_path, options = {})
      raise ArgumentError, "text is required" unless text
      raise ArgumentError, "file_path is required" unless file_path

      logger.info("#{self.class.name}##{__method__} Writing to file: #{file_path}")

      params = {}
      params["-n"] = nil if options[:no_newline]
      params[nil] = [text]

      redirect = options[:append] ? ">>" : ">"
      cmd = "#{ECHO_CMD} #{params_to_string(params)} #{redirect} #{file_path}"
      
      Common.run!(cmd)
    end

    # Append text to a file
    # @param text [String] Text to append
    # @param file_path [String] File path to append to
    # @param options [Hash] Options for the append operation
    # @option options [Boolean] :no_newline Do not add trailing newline
    def self.append_to_file(text, file_path, options = {})
      options = options.merge(:append => true)
      write_to_file(text, file_path, options)
    end

    # Create a newline
    # @param count [Integer] Number of newlines to output (default: 1)
    def self.newline(count = 1)
      raise ArgumentError, "count must be positive" if count < 1

      logger.info("#{self.class.name}##{__method__} Outputting #{count} newline(s)")

      params = {}
      params["-e"] = nil
      params[nil] = ["\\n" * count]

      Common.run!(ECHO_CMD, :params => params)
    end

    # Output text with backslash interpretation
    # @param text [String] Text with backslash escapes to interpret
    # @param options [Hash] Options for the echo operation
    def self.interpret(text, options = {})
      options = options.merge(:interpret_backslash => true)
      output(text, options)
    end

    # Output text without trailing newline
    # @param text [String] Text to output
    # @param options [Hash] Options for the echo operation
    def self.print(text, options = {})
      options = options.merge(:no_newline => true)
      output(text, options)
    end

    # Create a file with content
    # @param file_path [String] File path to create
    # @param content [String] Content to write to file
    # @param options [Hash] Options for the file creation
    # @option options [Boolean] :overwrite Overwrite existing file
    def self.create_file(file_path, content, options = {})
      raise ArgumentError, "file_path is required" unless file_path
      raise ArgumentError, "content is required" unless content

      logger.info("#{self.class.name}##{__method__} Creating file: #{file_path}")

      # Check if file exists and overwrite is not allowed
      if File.exist?(file_path) && !options[:overwrite]
        raise ArgumentError, "File #{file_path} already exists. Use :overwrite => true to overwrite."
      end

      write_to_file(content, file_path, options)
    end

    # Read and output file contents
    # @param file_path [String] File path to read
    # @param options [Hash] Options for the read operation
    # @option options [Boolean] :no_newline Do not add trailing newline
    def self.read_file(file_path, options = {})
      raise ArgumentError, "file_path is required" unless file_path
      raise ArgumentError, "File #{file_path} does not exist" unless File.exist?(file_path)

      logger.info("#{self.class.name}##{__method__} Reading file: #{file_path}")

      content = File.read(file_path)
      output(content, options)
    end

    # Check if echo command is available
    # @return [Boolean] True if echo is available
    def self.available?
      Common.cmd?(:echo)
    end

    private

    # Convert params hash to command line string
    # @param params [Hash] Parameters hash
    # @return [String] Command line string
    def self.params_to_string(params)
      parts = []
      params.each do |key, value|
        if key.nil?
          parts << value
        elsif value.nil?
          parts << key
        else
          parts << "#{key} #{value}"
        end
      end
      parts.join(" ")
    end
  end
end
