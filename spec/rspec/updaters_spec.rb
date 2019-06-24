# frozen_string_literal: true

RSpec.describe Rspec::RequestSnapshot do
  context "when updating json" do
    around do |example|
      ClimateControl.modify CONSERVATIVE_UPDATE_SNAPSHOTS: "true" do
        example.run
      end
    end

    let(:snapshot_path) { File.join(Dir.pwd, RSpec.configuration.request_snapshots_dir, "#{snapshot_name}.json") }
    let(:old_snapshot_content) { File.read(snapshot_path) }

    before do
      old_snapshot_content
      expect(json).to match_snapshot(snapshot_name)
    end

    after { File.write(snapshot_path, old_snapshot_content) }

    context "when updating simple hash elements" do
      let(:snapshot_name) { "updaters/simple_json" }
      let(:json) { { object: { book: { id: 10, name: "Name changed" } } }.to_json }

      it "updates snapshot node value" do
        expected_json = { object: { book: { id: 1, name: "Name changed" } } }.to_json
        expect(File.read(snapshot_path)).to eq(expected_json)
      end
    end

    context "when adding a new node" do
      let(:snapshot_name) { "updaters/add_json" }
      let(:json) { { object: { book: { id: 10, name: "Name changed", value: 29.99 } } }.to_json }

      it "updates snapshot adding the new node" do
        expected_json = { object: { book: { id: 1, name: "Name changed", value: 29.99 } } }.to_json
        expect(File.read(snapshot_path)).to eq(expected_json)
      end
    end

    context "when removing a node" do
      let(:snapshot_name) { "updaters/remove_json" }
      let(:json) { { object: { book: { id: 10, name: "Name changed" } } }.to_json }

      it "updates snapshot adding the new node" do
        expected_json = { object: { book: { id: 1, name: "Name changed" } } }.to_json
        expect(File.read(snapshot_path)).to eq(expected_json)
      end
    end

    context "when updating array node values" do
      let(:snapshot_name) { "updaters/array_node_json" }
      let(:json) {
        {
          objects: [
            { id: 10, name: "1st name", value: 29.99 },
            { id: 20, name: "2nd name", value: 10.00 }
          ],
          meta: { success: true }
        }.to_json
      }

      it "updates snapshot array node values" do
        expected_json = {
          objects: [{ id: 1, name: "1st name", value: 29.99 }, { id: 2, name: "2nd name", value: 10.00 }],
          meta: { success: true }
        }.to_json
        expect(File.read(snapshot_path)).to eq(expected_json)
      end
    end

    context "when adding array element" do
      let(:snapshot_name) { "updaters/array_add_node_json" }
      let(:json) {
        {
          objects: [
            { id: 10, name: "1st name", value: 29.99 },
            { id: 20, name: "2nd name", value: 10.00 }
          ],
          meta: { success: true }
        }.to_json
      }

      it "updates snapshot by adding node" do
        expected_json = {
          objects: [{ id: 1, name: "1st name", value: 29.99 }, { id: 20, name: "2nd name", value: 10.00 }],
          meta: { success: true }
        }.to_json
        expect(File.read(snapshot_path)).to eq(expected_json)
      end
    end

    context "when removing array element" do
      let(:snapshot_name) { "updaters/array_remove_node_json" }
      let(:json) {
        {
          objects: [
            { id: 10, name: "1st name", value: 29.99 }
          ],
          meta: { success: true }
        }.to_json
      }

      it "updates snapshot by removing node" do
        expected_json = {
          objects: [{ id: 1, name: "1st name", value: 29.99 }],
          meta: { success: true }
        }.to_json
        expect(File.read(snapshot_path)).to eq(expected_json)
      end
    end
  end
end
