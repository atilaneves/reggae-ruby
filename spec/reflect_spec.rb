require 'reggae'

RSpec.describe BuildFinder, '::get_build' do
  it 'finds the build in this file' do
    expect(BuildFinder.get_build).to eq $build
  end
end


$build = Build.new(Target.new('foo', 'dmd -offoo foo.d', [Target.new('foo.d')]))
