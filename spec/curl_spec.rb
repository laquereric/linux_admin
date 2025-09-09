require 'spec_helper'

describe LinuxAdmin::Curl do
  describe ".download" do
    it "downloads from URL" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {nil => ["http://example.com/file.txt"]}
      )
      described_class.download("http://example.com/file.txt")
    end

    it "downloads with output file" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-o" => "output.txt", nil => ["http://example.com/file.txt"]}
      )
      described_class.download("http://example.com/file.txt", :output => "output.txt")
    end

    it "downloads with follow redirects" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-L" => nil, nil => ["http://example.com/file.txt"]}
      )
      described_class.download("http://example.com/file.txt", :follow_redirects => true)
    end

    it "downloads with timeout" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"--connect-timeout" => 30, "--max-time" => 30, nil => ["http://example.com/file.txt"]}
      )
      described_class.download("http://example.com/file.txt", :timeout => 30)
    end

    it "downloads with headers" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-H" => "Accept: application/json", "-H" => "User-Agent: MyApp", nil => ["http://example.com/file.txt"]}
      )
      described_class.download("http://example.com/file.txt", :headers => {"Accept" => "application/json", "User-Agent" => "MyApp"})
    end

    it "downloads with authentication" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-u" => "user:pass", nil => ["http://example.com/file.txt"]}
      )
      described_class.download("http://example.com/file.txt", :username => "user", :password => "pass")
    end

    it "downloads with insecure option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-k" => nil, nil => ["https://example.com/file.txt"]}
      )
      described_class.download("https://example.com/file.txt", :insecure => true)
    end

    it "raises error when url is missing" do
      expect { described_class.download(nil) }.to raise_error(ArgumentError, "url is required")
    end
  end

  describe ".upload" do
    it "uploads a file" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-X" => "POST", "-T" => "file.txt", nil => ["http://example.com/upload"]}
      )
      described_class.upload("http://example.com/upload", "file.txt")
    end

    it "uploads with PUT method" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-X" => "PUT", "-T" => "file.txt", nil => ["http://example.com/upload"]}
      )
      described_class.upload("http://example.com/upload", "file.txt", :method => "PUT")
    end

    it "uploads with data when content-type is set" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-X" => "POST", "-H" => "Content-Type: application/json", "-d" => "@file.txt", nil => ["http://example.com/upload"]}
      )
      described_class.upload("http://example.com/upload", "file.txt", :headers => {"Content-Type" => "application/json"})
    end

    it "raises error when url is missing" do
      expect { described_class.upload(nil, "file.txt") }.to raise_error(ArgumentError, "url is required")
    end

    it "raises error when file is missing" do
      expect { described_class.upload("http://example.com", nil) }.to raise_error(ArgumentError, "file is required")
    end
  end

  describe ".request" do
    it "makes a GET request" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {nil => ["http://example.com"]}
      )
      described_class.request("http://example.com")
    end

    it "makes a POST request with data" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-X" => "POST", "-d" => "data", nil => ["http://example.com"]}
      )
      described_class.request("http://example.com", :method => "POST", :data => "data")
    end

    it "makes request with silent option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-s" => nil, nil => ["http://example.com"]}
      )
      described_class.request("http://example.com", :silent => true)
    end

    it "makes request with show_headers option" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-i" => nil, nil => ["http://example.com"]}
      )
      described_class.request("http://example.com", :show_headers => true)
    end

    it "raises error when url is missing" do
      expect { described_class.request(nil) }.to raise_error(ArgumentError, "url is required")
    end
  end

  describe ".head" do
    it "makes a HEAD request" do
      expect(LinuxAdmin::Common).to receive(:run!).with(
        LinuxAdmin::Curl::CURL_CMD,
        :params => {"-X" => "HEAD", "-s" => nil, nil => ["http://example.com"]}
      )
      described_class.head("http://example.com")
    end
  end

  describe ".accessible?" do
    it "returns true for accessible URL" do
      result = double("result", :output => "HTTP/1.1 200 OK\nContent-Type: text/html")
      allow(described_class).to receive(:head).and_return(result)
      expect(described_class.accessible?("http://example.com")).to be true
    end

    it "returns false for inaccessible URL" do
      result = double("result", :output => "HTTP/1.1 404 Not Found")
      allow(described_class).to receive(:head).and_return(result)
      expect(described_class.accessible?("http://example.com/nonexistent")).to be false
    end

    it "returns false when request fails" do
      allow(described_class).to receive(:head).and_raise(StandardError)
      expect(described_class.accessible?("http://example.com")).to be false
    end
  end

  describe ".status_code" do
    it "returns status code for successful request" do
      result = double("result", :output => "HTTP/1.1 200 OK\nContent-Type: text/html")
      allow(described_class).to receive(:head).and_return(result)
      expect(described_class.status_code("http://example.com")).to eq(200)
    end

    it "returns status code for error request" do
      result = double("result", :output => "HTTP/1.1 404 Not Found")
      allow(described_class).to receive(:head).and_return(result)
      expect(described_class.status_code("http://example.com/nonexistent")).to eq(404)
    end

    it "returns nil when request fails" do
      allow(described_class).to receive(:head).and_raise(StandardError)
      expect(described_class.status_code("http://example.com")).to be_nil
    end
  end

  describe ".available?" do
    it "returns true when curl is available" do
      expect(LinuxAdmin::Common).to receive(:cmd?).with(:curl).and_return(true)
      expect(described_class.available?).to be true
    end

    it "returns false when curl is not available" do
      expect(LinuxAdmin::Common).to receive(:cmd?).with(:curl).and_return(false)
      expect(described_class.available?).to be false
    end
  end
end
