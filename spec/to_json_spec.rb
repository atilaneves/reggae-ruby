require 'reggae'

RSpec.describe Target, '#to_json' do
  context 'Leaf target' do
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
end
