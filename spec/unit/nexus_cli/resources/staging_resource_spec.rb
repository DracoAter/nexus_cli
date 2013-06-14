require 'spec_helper'

describe NexusCli::StagingResource do
  let(:staging_resource) { described_class.new(connection_registry) }
  let(:connection_registry) { double(:[] => connection) }
  let(:connection) { double(:put => response, :post => response) }
  let(:response) { double(:body => {}, :headers => {}) }
  let(:repository_id) { "123" }

  describe "#upload" do
    let(:upload) { staging_resource.upload(artifact_id, file) }
    let(:artifact_id) { "com.mytest:test:1.0.0:tgz" }
    let(:file) { double }

    before do
      File.stub(:read).and_return("contents")
    end

    it "uploads to the default path" do
      connection.should_receive(:put).with(/staging\/deploy\/maven2/, "contents")
      upload
    end

    context "when a repository_id is given" do
      let(:upload) { staging_resource.upload(artifact_id, repository_id, file) }

      it "uploads to the specified repository" do
        connection.should_receive(:put).with(/staging\/deployByRepositoryId\/123/, "contents")
        upload
      end
    end
  end

  describe "#close" do
    let(:close) { staging_resource.close(repository_id) }
    let(:payload) do
      {
        :data => {
          :stagedRepositoryIds => [repository_id],
          :description => "some description"
        }
      }
    end

    it "closes the staging repository" do
      connection.should_receive(:post).with(/staging\/bulk\/close/, kind_of(String))
      close
    end
  end

  describe "drop" do

  end

end