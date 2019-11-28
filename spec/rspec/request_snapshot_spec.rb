# frozen_string_literal: true

RSpec.describe Rspec::RequestSnapshot do
  it "has a version number" do
    expect(Rspec::RequestSnapshot::VERSION).not_to be nil
  end

  describe "snapshot matching" do
    context "when snapshot does not exist" do
      let(:snapshot_path) { File.join(Dir.pwd, RSpec.configuration.request_snapshots_dir, "temp.json") }

      after { FileUtils.rm_f(snapshot_path) }

      it "creates a new snapshot file" do
        expect({ a: 1 }.to_json).to match_snapshot("temp")
        expect(File.exist?(snapshot_path)).to be_truthy
      end

      context "when BLOCK_CREATE_SNAPSHOTS flag is true" do
        around do |example|
          ClimateControl.modify BLOCK_CREATE_SNAPSHOTS: "true" do
            example.run
          end
        end

        it "does not create a new snapshot file" do
          expect({ a: 1 }.to_json).not_to match_snapshot("temp")
          expect(File.exist?(snapshot_path)).to be_falsy
        end
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
      json = { id: 99, created_at: false, updated_at: Time.now.iso8601 }.to_json
      expect(json).to match_snapshot("api/dynamic_attributes")
    end

    it "ignores passed dynamic attributes" do
      json = { custom: "different value from snapshot" }.to_json
      expect(json).to match_snapshot("api/custom_dynamic_attributes", dynamic_attributes: %w(custom))
    end

    it "ignores nodes inside object arrays" do
      json = { objects: [{ id: 10, value: "value 10" }, { id: 22, value: "value 20" }] }.to_json
      expect(json).to match_snapshot("api/array_dynamic_attributes", dynamic_attributes: %w(id))
    end
  end

  describe "regex dynamic attributes" do
    it "matches with matching regex" do
      json = { id: 99, created_at: false, updated_at: Time.now }.to_json
      expect(json).to match_snapshot("api/dynamic_attributes", dynamic_attributes: [{ id: /^\d{2}$/ }])
    end

    it "matches with partial matching regex" do
      json = { id: 999, created_at: false, updated_at: Time.now }.to_json
      expect(json).to match_snapshot("api/dynamic_attributes", dynamic_attributes: [{ id: /\d{2}/ }])
    end

    it "fails with not matching regex" do
      json = { id: 100, created_at: false, updated_at: Time.now }.to_json
      expect(json).not_to match_snapshot("api/dynamic_attributes", dynamic_attributes: [{ id: /^\d{2}$/ }])
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

    it "ignores ordering for object arrays" do
      json = { objects: [{ id: 20, value: "value 20" }, { id: 10, value: "value 10" }] }.to_json
      expect(json).to match_snapshot("api/ordering_objects", ignore_order: %w(objects))
    end

    context "when setting ignore_order configuration" do
      before { RSpec.configuration.request_snapshots_ignore_order = %w(unordered) }
      after { RSpec.configuration.request_snapshots_ignore_order = %w() }

      it "ignores ordering for nodes that are in ignore_order" do
        json = { id: 100, values: { ordered: [1, 2, 3], unordered: [8, 3, 7] } }.to_json
        expect(json).to match_snapshot("api/ordering")
      end
    end
  end

  describe "complex scenarios" do
    describe "json with nested dynamic attributes and ordering" do
      let(:complex_json) do
        {
          data: {
            books: [{ id: 22, name: "two" }, { id: 11, name: "one" }],
            value: "value"
          },
          objects: [
            {
              pens: [
                { id: 40, name: "one", prices: [1, 3, 2] },
                { id: 50, name: "two", prices: [7, 5, 6] }
              ],
              computers: [
                {
                  id: 10,
                  name: "computer two",
                  pieces: [
                    { id: 10, name: "one", prices: [11, 12, 13] },
                    { id: 20, name: "two", prices: [14, 15, 16] },
                    { id: 30, name: "three", prices: [17, 18, 19] }
                  ]
                },
                {
                  id: 20,
                  name: "computer one",
                  pieces: [
                    { id: 20, name: "one", prices: [1, 3, 2] },
                    { id: 10, name: "two", prices: [4, 5, 6] },
                    { id: 30, name: "three", prices: [9, 8, 7] }
                  ]
                }
              ]
            }
          ]
        }.to_json
      end

      it "matches snapshot for a complex scenario" do
        expect(complex_json).to match_snapshot(
          "api/complex_json", dynamic_attributes: %w(id), ignore_order: %w(books computers prices)
        )
      end
    end

    describe "json with ignore order for arrays with booleans and mixed data" do
      let(:complex_json) do
        {
          data: {
            items: [false, 8, true, "something", "3", 1]
          }
        }.to_json
      end

      it "matches snapshot for a scenario with complex ordering" do
        expect(complex_json).to match_snapshot(
          "api/complex_json_ordering", dynamic_attributes: %w(id), ignore_order: %w(items)
        )
      end
    end
  end

  describe "format" do
    let(:sample_text) { "My text test" }

    it "matches snapshot with text format" do
      expect(sample_text).to match_snapshot("api/text", format: :text)
    end

    it "defaults to json format when not specified" do
      expect(RSpec.configuration.request_snapshots_default_format).to eq :json
    end

    context "when the configured format is set to :text" do
      before { RSpec.configuration.request_snapshots_default_format = :text }
      after { RSpec.configuration.request_snapshots_default_format = :json }

      it "matches text without passing the format argument" do
        expect(sample_text).to match_snapshot("api/text")
      end
    end
  end

  describe "array json" do
    it "matches snapshot for array of hashes" do
      json = [{ id: 11, name: "A" }, { id: 21, name: "B" }].to_json
      expect(json).to match_snapshot("api/array")
    end

    it "matches snapshot for array of strings" do
      json = %w(A B).to_json
      expect(json).to match_snapshot("api/array_strings")
    end

    it "matches snapshot for array of arrays" do
      json = [[{ id: 31, name: "A" }], [{ id: 41, name: "B" }]].to_json
      expect(json).to match_snapshot("api/array_arrays")
    end
  end
end
