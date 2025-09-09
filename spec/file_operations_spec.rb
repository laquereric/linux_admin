require 'spec_helper'

describe LinuxAdmin::FileOperations do
  describe ".copy" do
    it "copies a file" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:cp),
        :params => {nil => ["source.txt", "dest.txt"]}
      )
      described_class.copy("source.txt", "dest.txt")
    end

    it "copies with recursive option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:cp),
        :params => {"-r" => nil, nil => ["source_dir", "dest_dir"]}
      )
      described_class.copy("source_dir", "dest_dir", :recursive => true)
    end

    it "copies with preserve option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:cp),
        :params => {"-p" => nil, nil => ["source.txt", "dest.txt"]}
      )
      described_class.copy("source.txt", "dest.txt", :preserve => true)
    end

    it "copies with force option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:cp),
        :params => {"-f" => nil, nil => ["source.txt", "dest.txt"]}
      )
      described_class.copy("source.txt", "dest.txt", :force => true)
    end

    it "raises error when source is missing" do
      expect { described_class.copy(nil, "dest.txt") }.to raise_error(ArgumentError, "source is required")
    end

    it "raises error when destination is missing" do
      expect { described_class.copy("source.txt", nil) }.to raise_error(ArgumentError, "destination is required")
    end
  end

  describe ".move" do
    it "moves a file" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:mv),
        :params => {nil => ["source.txt", "dest.txt"]}
      )
      described_class.move("source.txt", "dest.txt")
    end

    it "moves with force option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:mv),
        :params => {"-f" => nil, nil => ["source.txt", "dest.txt"]}
      )
      described_class.move("source.txt", "dest.txt", :force => true)
    end

    it "raises error when source is missing" do
      expect { described_class.move(nil, "dest.txt") }.to raise_error(ArgumentError, "source is required")
    end

    it "raises error when destination is missing" do
      expect { described_class.move("source.txt", nil) }.to raise_error(ArgumentError, "destination is required")
    end
  end

  describe ".chmod" do
    it "changes file permissions" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:chmod),
        :params => {nil => ["755", "file.txt"]}
      )
      described_class.chmod("755", "file.txt")
    end

    it "changes permissions with recursive option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:chmod),
        :params => {"-R" => nil, nil => ["755", "directory"]}
      )
      described_class.chmod("755", "directory", :recursive => true)
    end

    it "accepts integer mode" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:chmod),
        :params => {nil => ["755", "file.txt"]}
      )
      described_class.chmod(0755, "file.txt")
    end

    it "accepts array of targets" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:chmod),
        :params => {nil => ["755", "file1.txt", "file2.txt"]}
      )
      described_class.chmod("755", ["file1.txt", "file2.txt"])
    end

    it "raises error when mode is missing" do
      expect { described_class.chmod(nil, "file.txt") }.to raise_error(ArgumentError, "mode is required")
    end

    it "raises error when target is missing" do
      expect { described_class.chmod("755", nil) }.to raise_error(ArgumentError, "target is required")
    end
  end

  describe ".chown" do
    it "changes file ownership" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:chown),
        :params => {nil => ["user", "file.txt"]}
      )
      described_class.chown("user", "file.txt")
    end

    it "changes ownership with recursive option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:chown),
        :params => {"-R" => nil, nil => ["user:group", "directory"]}
      )
      described_class.chown("user:group", "directory", :recursive => true)
    end

    it "accepts array of targets" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:chown),
        :params => {nil => ["user", "file1.txt", "file2.txt"]}
      )
      described_class.chown("user", ["file1.txt", "file2.txt"])
    end

    it "raises error when owner is missing" do
      expect { described_class.chown(nil, "file.txt") }.to raise_error(ArgumentError, "owner is required")
    end

    it "raises error when target is missing" do
      expect { described_class.chown("user", nil) }.to raise_error(ArgumentError, "target is required")
    end
  end

  describe ".mkdir" do
    it "creates a directory" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:mkdir),
        :params => {nil => ["newdir"]}
      )
      described_class.mkdir("newdir")
    end

    it "creates directory with parents option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:mkdir),
        :params => {"-p" => nil, nil => ["path/to/newdir"]}
      )
      described_class.mkdir("path/to/newdir", :parents => true)
    end

    it "creates directory with mode option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:mkdir),
        :params => {"-m" => "755", nil => ["newdir"]}
      )
      described_class.mkdir("newdir", :mode => "755")
    end

    it "accepts array of paths" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Common.cmd(:mkdir),
        :params => {nil => ["dir1", "dir2"]}
      )
      described_class.mkdir(["dir1", "dir2"])
    end

    it "raises error when path is missing" do
      expect { described_class.mkdir(nil) }.to raise_error(ArgumentError, "path is required")
    end
  end

  describe ".command_exists?" do
    it "checks if command exists" do
      expect(LinuxAdmin::Common).to receive(:cmd?).with("testcmd").and_return(true)
      expect(described_class.command_exists?("testcmd")).to be true
    end

    it "returns false when command doesn't exist" do
      expect(LinuxAdmin::Common).to receive(:cmd?).with("nonexistent").and_return(false)
      expect(described_class.command_exists?("nonexistent")).to be false
    end
  end

  describe ".command_path" do
    it "returns command path" do
      expect(LinuxAdmin::Common).to receive(:cmd).with("testcmd").and_return("/usr/bin/testcmd")
      expect(described_class.command_path("testcmd")).to eq("/usr/bin/testcmd")
    end

    it "returns nil when command doesn't exist" do
      expect(LinuxAdmin::Common).to receive(:cmd).with("nonexistent").and_return(nil)
      expect(described_class.command_path("nonexistent")).to be_nil
    end
  end
end
