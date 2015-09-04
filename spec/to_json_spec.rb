require 'reggae'

RSpec.describe Target, '#to_json' do
  context 'Leaf target foo.d' do
    it 'returns correct json' do
      tgt = Target.new('foo.d')
      expect(tgt.to_json).to be_json_eql(
        '{"type": "fixed",
          "command": {},
          "outputs": ["foo.d"],
          "dependencies": {"type": "fixed", "targets": []},
          "implicits": {"type": "fixed", "targets": []}}')
    end
  end

  context 'Leaf target bar.d' do
    it 'returns correct json' do
      tgt = Target.new('bar.d')
      expect(tgt.to_json).to be_json_eql(
        '{"type": "fixed",
          "command": {},
          "outputs": ["bar.d"],
          "dependencies": {"type": "fixed", "targets": []},
          "implicits": {"type": "fixed", "targets": []}}')
    end
  end

  context 'build' do
    it 'returns correct json for a Build object' do
      build = Build.new(Target.new('foo',
                                   'dmd -offoo foo.d',
                                   [Target.new('foo.d')]))

      expect(build.to_json).to be_json_eql(
        '[{"type": "fixed",
          "command": {"type": "shell",
                      "cmd": "dmd -offoo foo.d"},
          "outputs": ["foo"],
          "dependencies": {"type": "fixed",
                           "targets":
                           [{"type": "fixed",
                             "command": {},
                           "outputs": ["foo.d"],
                           "dependencies": {
                               "type": "fixed",
                               "targets": []},
                           "implicits": {
                               "type": "fixed",
                               "targets": []}}]},
          "implicits": {"type": "fixed", "targets": []}}]')
    end
  end
end
