RSpec.describe Rspec::RequestSnapshot do
  it "has a version number" do
    expect(Rspec::RequestSnapshot::VERSION).not_to be nil
  end

  describe "snapshot machting" do
    context "when snapshot does not exist" do
      let(:snapshot_path) { File.join(Dir.pwd, RSpec.configuration.request_snapshots_dir, "temp.json") }

      after { FileUtils.rm(snapshot_path) }

      it "creates a new snapshot file" do
        expect({ a: 1 }.to_json).to match_snapshot("temp")
        expect(File.exist?(snapshot_path)).to be_truthy
      end
    end

    context "when snapshot exists" do
      it "matches snapshot from the file" do
        expect({ sample: "value" }.to_json).to match_snapshot("api/file")
      end

      it "does not match when snapshot file content is different" do
        expect({ sample: "other value" }.to_json).not_to match_snapshot("api/file")
      end

      context "with nested nodes" do
        it "matches snapshot from the file" do
          json = { nested: { level: { sample: "value", sample2: "value2" } } }.to_json
          expect(json).to match_snapshot("api/nested")
        end

        it "does not match when snapshot file content is different" do
          json = { nested: { level: { sample: "value", sample3: "value2" } } }.to_json
          expect(json).not_to match_snapshot("api/nested")
        end
      end
    end
  end

  describe "dynamic attributes" do
    it "ignores default dynamic attributes" do
      json = { id: 99, created_at: false, updated_at: Time.now }.to_json
      expect(json).to match_snapshot("api/dynamic_attributes")
    end

    it "ignores passed dynamic attributes" do
      json = { custom: "different value from snapshot" }.to_json
      expect(json).to match_snapshot("api/custom_dynamic_attributes", dynamic_attributes: %w(custom))
    end
  end

  describe "ordering" do
    it "ignores ordering for nodes that are in ignore_order" do
      json = { id: 100, values: { ordered: [1, 2, 3], unordered: [8, 3, 7] } }.to_json
      expect(json).to match_snapshot("api/ordering", ignore_order: %w(unordered))
    end

    it "does not match if ordering is different and we dont ignore" do
      json = { id: 100, values: { ordered: [1, 2, 3], unordered: [8, 3, 7] } }.to_json
      expect(json).not_to match_snapshot("api/ordering")
    end
  end

  describe "format" do
    it "matches snapshot with text format" do
      expect("My text test").to match_snapshot("api/text", format: :text)
    end
  end
end
