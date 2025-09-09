require 'spec_helper'

describe LinuxAdmin::Apt do
  describe ".update" do
    it "updates package lists" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"update" => nil}
      )
      described_class.update
    end

    it "updates with assume_yes option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"-y" => nil, "update" => nil}
      )
      described_class.update(:assume_yes => true)
    end

    it "updates with quiet option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"-q" => nil, "update" => nil}
      )
      described_class.update(:quiet => true)
    end
  end

  describe ".install" do
    it "installs a package" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"install" => nil, nil => ["package1"]}
      )
      described_class.install("package1")
    end

    it "installs multiple packages" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"install" => nil, nil => ["package1", "package2"]}
      )
      described_class.install(["package1", "package2"])
    end

    it "installs with assume_yes option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"-y" => nil, "install" => nil, nil => ["package1"]}
      )
      described_class.install("package1", :assume_yes => true)
    end

    it "installs with fix_broken option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"-f" => nil, "install" => nil, nil => ["package1"]}
      )
      described_class.install("package1", :fix_broken => true)
    end

    it "raises error when packages are missing" do
      expect { described_class.install(nil) }.to raise_error(ArgumentError, "packages are required")
    end
  end

  describe ".remove" do
    it "removes a package" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"remove" => nil, nil => ["package1"]}
      )
      described_class.remove("package1")
    end

    it "removes with purge option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"--purge" => nil, "purge" => nil, nil => ["package1"]}
      )
      described_class.remove("package1", :purge => true)
    end

    it "raises error when packages are missing" do
      expect { described_class.remove(nil) }.to raise_error(ArgumentError, "packages are required")
    end
  end

  describe ".upgrade" do
    it "upgrades packages" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"upgrade" => nil}
      )
      described_class.upgrade
    end

    it "performs distribution upgrade" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"dist-upgrade" => nil}
      )
      described_class.upgrade(:dist_upgrade => true)
    end
  end

  describe ".search" do
    it "searches for packages" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_CMD,
        :params => {"search" => nil, nil => ["pattern"]}
      )
      described_class.search("pattern")
    end

    it "raises error when pattern is missing" do
      expect { described_class.search(nil) }.to raise_error(ArgumentError, "pattern is required")
    end
  end

  describe ".show" do
    it "shows package information" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_CMD,
        :params => {"show" => nil, nil => ["package1"]}
      )
      described_class.show("package1")
    end

    it "raises error when package is missing" do
      expect { described_class.show(nil) }.to raise_error(ArgumentError, "package is required")
    end
  end

  describe ".list_installed" do
    it "lists installed packages" do
      result = double("result", :output => "package1/1.0 amd64 [installed] Description\npackage2/2.0 amd64 [installed] Description")
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_CMD,
        :params => {"--installed" => nil, "list" => nil}
      ).and_return(result)

      packages = described_class.list_installed
      expect(packages).to have(2).items
      expect(packages[0][:name]).to eq("package1")
      expect(packages[0][:version]).to eq("1.0")
      expect(packages[0][:architecture]).to eq("amd64")
      expect(packages[0][:status]).to eq("installed")
    end

    it "lists installed packages with pattern" do
      result = double("result", :output => "package1/1.0 amd64 [installed] Description")
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_CMD,
        :params => {"--installed" => nil, "list" => nil, nil => ["pattern"]}
      ).and_return(result)

      described_class.list_installed(:pattern => "pattern")
    end
  end

  describe ".list_upgradable" do
    it "lists upgradable packages" do
      result = double("result", :output => "package1/1.0 amd64 [upgradable] Description")
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_CMD,
        :params => {"--upgradable" => nil, "list" => nil}
      ).and_return(result)

      packages = described_class.list_upgradable
      expect(packages).to have(1).item
      expect(packages[0][:name]).to eq("package1")
    end
  end

  describe ".clean" do
    it "cleans package cache" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"clean" => nil}
      )
      described_class.clean
    end

    it "performs autoclean" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Apt::APT_GET_CMD,
        :params => {"autoclean" => nil}
      )
      described_class.clean(:autoclean => true)
    end
  end

  describe ".updates_available?" do
    it "returns true when updates are available" do
      allow(described_class).to receive(:list_upgradable).and_return([{:name => "package1"}])
      expect(described_class.updates_available?).to be true
    end

    it "returns false when no updates are available" do
      allow(described_class).to receive(:list_upgradable).and_return([])
      expect(described_class.updates_available?).to be false
    end
  end

  describe ".parse_package_list" do
    it "parses package list output" do
      output = "package1/1.0 amd64 [installed] Description line 1\npackage2/2.0 amd64 [upgradable] Description line 2"
      packages = described_class.send(:parse_package_list, output)
      
      expect(packages).to have(2).items
      expect(packages[0][:name]).to eq("package1")
      expect(packages[0][:version]).to eq("1.0")
      expect(packages[0][:architecture]).to eq("amd64")
      expect(packages[0][:status]).to eq("installed")
      expect(packages[0][:description]).to eq("Description line 1")
    end

    it "ignores empty lines and warnings" do
      output = "\nWARNING: Some warning\npackage1/1.0 amd64 [installed] Description\n"
      packages = described_class.send(:parse_package_list, output)
      
      expect(packages).to have(1).item
      expect(packages[0][:name]).to eq("package1")
    end
  end
end
