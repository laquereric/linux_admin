require 'spec_helper'

describe LinuxAdmin::Echo do
  describe ".output" do
    it "outputs text" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Echo::ECHO_CMD,
        :params => {nil => ["Hello World"]}
      )
      described_class.output("Hello World")
    end

    it "outputs text without newline" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Echo::ECHO_CMD,
        :params => {"-n" => nil, nil => ["Hello World"]}
      )
      described_class.output("Hello World", :no_newline => true)
    end

    it "outputs text with backslash interpretation" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Echo::ECHO_CMD,
        :params => {"-e" => nil, nil => ["Hello\\nWorld"]}
      )
      described_class.output("Hello\\nWorld", :interpret_backslash => true)
    end

    it "outputs text to file" do
      expect(LinuxAdmin::Common).to receive(:run!).with("echo Hello World > output.txt")
      described_class.output("Hello World", :output_file => "output.txt")
    end

    it "raises error when text is missing" do
      expect { described_class.output(nil) }.to raise_error(ArgumentError, "text is required")
    end
  end

  describe ".write_to_file" do
    it "writes text to file" do
      expect(LinuxAdmin::Common).to receive(:run!).with("echo Hello World > file.txt")
      described_class.write_to_file("Hello World", "file.txt")
    end

    it "writes text to file without newline" do
      expect(LinuxAdmin::Common).to receive(:run!).with("echo -n Hello World > file.txt")
      described_class.write_to_file("Hello World", "file.txt", :no_newline => true)
    end

    it "appends text to file" do
      expect(LinuxAdmin::Common).to receive(:run!).with("echo Hello World >> file.txt")
      described_class.write_to_file("Hello World", "file.txt", :append => true)
    end

    it "raises error when text is missing" do
      expect { described_class.write_to_file(nil, "file.txt") }.to raise_error(ArgumentError, "text is required")
    end

    it "raises error when file_path is missing" do
      expect { described_class.write_to_file("Hello", nil) }.to raise_error(ArgumentError, "file_path is required")
    end
  end

  describe ".append_to_file" do
    it "appends text to file" do
      expect(LinuxAdmin::Common).to receive(:run!).with("echo Hello World >> file.txt")
      described_class.append_to_file("Hello World", "file.txt")
    end

    it "appends text without newline" do
      expect(LinuxAdmin::Common).to receive(:run!).with("echo -n Hello World >> file.txt")
      described_class.append_to_file("Hello World", "file.txt", :no_newline => true)
    end
  end

  describe ".newline" do
    it "outputs a single newline" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Echo::ECHO_CMD,
        :params => {"-e" => nil, nil => ["\\n"]}
      )
      described_class.newline
    end

    it "outputs multiple newlines" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Echo::ECHO_CMD,
        :params => {"-e" => nil, nil => ["\\n\\n\\n"]}
      )
      described_class.newline(3)
    end

    it "raises error for invalid count" do
      expect { described_class.newline(0) }.to raise_error(ArgumentError, "count must be positive")
      expect { described_class.newline(-1) }.to raise_error(ArgumentError, "count must be positive")
    end
  end

  describe ".interpret" do
    it "outputs text with backslash interpretation" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Echo::ECHO_CMD,
        :params => {"-e" => nil, nil => ["Hello\\nWorld"]}
      )
      described_class.interpret("Hello\\nWorld")
    end
  end

  describe ".print" do
    it "outputs text without newline" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Echo::ECHO_CMD,
        :params => {"-n" => nil, nil => ["Hello World"]}
      )
      described_class.print("Hello World")
    end
  end

  describe ".create_file" do
    before do
      allow(File).to receive(:exist?).and_return(false)
    end

    it "creates a file with content" do
      expect(LinuxAdmin::Common).to receive(:run!).with("echo Hello World > file.txt")
      described_class.create_file("file.txt", "Hello World")
    end

    it "creates file with overwrite option" do
      allow(File).to receive(:exist?).with("file.txt").and_return(true)
      expect(LinuxAdmin::Common).to receive(:run!).with("echo Hello World > file.txt")
      described_class.create_file("file.txt", "Hello World", :overwrite => true)
    end

    it "raises error when file exists and overwrite is false" do
      allow(File).to receive(:exist?).with("file.txt").and_return(true)
      expect { described_class.create_file("file.txt", "Hello World") }.to raise_error(ArgumentError, "File file.txt already exists. Use :overwrite => true to overwrite.")
    end

    it "raises error when file_path is missing" do
      expect { described_class.create_file(nil, "content") }.to raise_error(ArgumentError, "file_path is required")
    end

    it "raises error when content is missing" do
      expect { described_class.create_file("file.txt", nil) }.to raise_error(ArgumentError, "content is required")
    end
  end

  describe ".read_file" do
    before do
      allow(File).to receive(:exist?).with("file.txt").and_return(true)
      allow(File).to receive(:read).with("file.txt").and_return("File content")
    end

    it "reads and outputs file content" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Echo::ECHO_CMD,
        :params => {nil => ["File content"]}
      )
      described_class.read_file("file.txt")
    end

    it "reads file without newline" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Echo::ECHO_CMD,
        :params => {"-n" => nil, nil => ["File content"]}
      )
      described_class.read_file("file.txt", :no_newline => true)
    end

    it "raises error when file_path is missing" do
      expect { described_class.read_file(nil) }.to raise_error(ArgumentError, "file_path is required")
    end

    it "raises error when file doesn't exist" do
      allow(File).to receive(:exist?).with("nonexistent.txt").and_return(false)
      expect { described_class.read_file("nonexistent.txt") }.to raise_error(ArgumentError, "File nonexistent.txt does not exist")
    end
  end

  describe ".available?" do
    it "returns true when echo is available" do
      expect(LinuxAdmin::Common).to receive(:cmd?).with(:echo).and_return(true)
      expect(described_class.available?).to be true
    end

    it "returns false when echo is not available" do
      expect(LinuxAdmin::Common).to receive(:cmd?).with(:echo).and_return(false)
      expect(described_class.available?).to be false
    end
  end

  describe ".params_to_string" do
    it "converts params hash to command line string" do
      params = {"-n" => nil, nil => ["Hello World"]}
      result = described_class.send(:params_to_string, params)
      expect(result).to eq("-n Hello World")
    end

    it "handles params with values" do
      params = {"-o" => "output.txt", nil => ["Hello World"]}
      result = described_class.send(:params_to_string, params)
      expect(result).to eq("-o output.txt Hello World")
    end

    it "handles multiple nil keys" do
      params = {nil => ["Hello", "World"]}
      result = described_class.send(:params_to_string, params)
      expect(result).to eq("Hello World")
    end
  end
end
