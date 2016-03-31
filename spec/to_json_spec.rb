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

  context 'build with helper functions' do
    it 'returns correct json for a Build object' do
      bld = build(target('foo',
                         'dmd -offoo foo.d',
                         [target('foo.d')]))

      expect(bld.to_json).to be_json_eql(
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

  context 'project dir include' do
    it 'returns the correct json for $projectdir in command' do
      main_obj = Target.new('main.o',
                            'dmd -I$project/src -c $in -of$out',
                            Target.new('src/main.d'))
      expect(main_obj.to_json).to be_json_eql(
        '{"type": "fixed",
          "command": {"type": "shell",
                      "cmd": "dmd -I$project/src -c $in -of$out"},
          "outputs": ["main.o"],
          "dependencies": {"type": "fixed",
                           "targets": [
                               {"type": "fixed",
                                "command": {}, "outputs": ["src/main.d"],
                                "dependencies": {
                                    "type": "fixed",
                                    "targets": []},
                                "implicits": {
                                    "type": "fixed",
                                    "targets": []}}]},
          "implicits": {
              "type": "fixed",
              "targets": []}}')
    end
  end

  context 'link fixed' do
    it 'returns the correct json for the link rule with fixed targets' do
      main_obj = Target.new('main.o',
                            'dmd -I$project/src -c $in -of$out',
                            Target.new('src/main.d'))
      maths_obj = Target.new('maths.o',
                             'dmd -c $in -of$out',
                             Target.new('src/maths.d'))
      app = link(exe_name: 'myapp',
                 dependencies: [main_obj, maths_obj],
                 flags: '-L-M')
      bld = Build.new(app)
      expect(bld.to_json).to be_json_eql(
        '[{"type": "fixed",
          "command": {"type": "link", "flags": "-L-M"},
          "outputs": ["myapp"],
          "dependencies": {
              "type": "fixed",
              "targets":
              [{"type": "fixed",
                "command": {"type": "shell",
                            "cmd": "dmd -I$project/src -c $in -of$out"},
                "outputs": ["main.o"],
                "dependencies": {"type": "fixed",
                                 "targets": [
                                     {"type": "fixed",
                                      "command": {}, "outputs": ["src/main.d"],
                                      "dependencies": {
                                          "type": "fixed",
                                          "targets": []},
                                      "implicits": {
                                          "type": "fixed",
                                          "targets": []}}]},
                "implicits": {
                    "type": "fixed",
                    "targets": []}},
               {"type": "fixed",
                "command": {"type": "shell", "cmd":
                            "dmd -c $in -of$out"},
                "outputs": ["maths.o"],
                "dependencies": {
                    "type": "fixed",
                    "targets": [
                        {"type": "fixed",
                         "command": {}, "outputs": ["src/maths.d"],
                         "dependencies": {
                             "type": "fixed",
                             "targets": []},
                         "implicits": {
                             "type": "fixed",
                             "targets": []}}]},
                "implicits": {
                    "type": "fixed",
                    "targets": []}}]},
          "implicits": {
              "type": "fixed",
              "targets": []}}]')
    end
  end

  context 'link dynamic' do
    it 'returns the correct json for the link rule with dynamic targets'do
      objs = object_files(flags: '-I$project/src', src_dirs: ['src'])
      app = link(exe_name: 'myapp', dependencies: objs, flags: '-L-M')
      bld = Build.new(app)
      expect(bld.to_json).to be_json_eql(
        '[{"type": "fixed",
          "command": {"type": "link", "flags": "-L-M"},
          "outputs": ["myapp"],
          "dependencies": {
              "type": "dynamic",
              "func": "objectFiles",
              "src_dirs": ["src"],
              "exclude_dirs": [],
              "src_files": [],
              "exclude_files": [],
              "flags": "-I$project/src",
              "includes": [],
              "string_imports": []},
          "implicits": {
              "type": "fixed",
              "targets": []}}]')
    end
  end

  context 'static lib' do
    it 'returns the correct json for the static library rule' do
      lib = static_library('libstuff.a',
                           flags: '-I$project/src',
                           src_dirs: ['src'])
      app = link(exe_name: 'myapp',
                 dependencies: lib,
                 flags: '-L-M')
      bld = Build.new(app)
      expect(bld.to_json).to be_json_eql(
        '[{"type": "fixed",
          "command": {"type": "link", "flags": "-L-M"},
          "outputs": ["myapp"],
          "dependencies": {
              "type": "dynamic",
              "func": "staticLibrary",
              "name": "libstuff.a",
              "src_dirs": ["src"],
              "exclude_dirs": [],
              "src_files": [],
              "exclude_files": [],
              "flags": "-I$project/src",
              "includes": [],
              "string_imports": []},
          "implicits": {
              "type": "fixed",
              "targets": []}}]')
    end
  end

  context 'scriptlike' do
    it 'returns the correct json for the scriptlike rule' do
      app = scriptlike(src_name: 'src/main.d',
                       exe_name: 'leapp',
                       flags: '-g',
                       includes: ['src'])
      bld = Build.new(app)
      expect(bld.to_json).to be_json_eql(
        '[{"type": "dynamic",
          "func": "scriptlike",
          "src_name": "src/main.d",
          "exe_name": "leapp",
          "link_with": {"type": "fixed", "targets": []},
          "flags": "-g",
          "includes": ["src"],
          "string_imports": []}]')
    end
  end

  context 'build with two targtes' do
    it 'returns the correct json when a build has two top-level targets' do
      objs1 = object_files(flags: '-I$project/src',
                           src_dirs: ['src'])
      app1 = link(exe_name: 'app1',
                  dependencies: objs1,
                  flags: '-L-M')
      objs2 = object_files(flags: '-I$project/other',
                           src_dirs: %w(other yetanother))
      app2 = link(exe_name: 'app2',
                  dependencies: objs2)

      bld = Build.new(app1, app2)

      expect(bld.to_json).to be_json_eql(
        '[{"type": "fixed",
          "command": {"type": "link", "flags": "-L-M"},
          "outputs": ["app1"],
          "dependencies": {
              "type": "dynamic",
              "func": "objectFiles",
              "src_dirs": ["src"],
              "exclude_dirs": [],
              "src_files": [],
              "exclude_files": [],
              "flags": "-I$project/src",
              "includes": [],
              "string_imports": []},
          "implicits": {
              "type": "fixed",
              "targets": []}},
         {"type": "fixed",
          "command": {"type": "link", "flags": ""},
          "outputs": ["app2"],
          "dependencies": {
              "type": "dynamic",
              "func": "objectFiles",
              "src_dirs": ["other", "yetanother"],
              "exclude_dirs": [],
              "src_files": [],
              "exclude_files": [],
              "flags": "-I$project/other",
              "includes": [],
              "string_imports": []},
          "implicits": {
              "type": "fixed",
              "targets": []}}]'
      )
    end
  end

  context 'dynamic target concatenation' do
    it 'returns the correct json when a dynamic target is used in an array' do
      main_obj = Target.new('main.o',
                            'dmd -I$project/src -c $in -of$out',
                            Target.new('src/main.d'))
      objs = object_files(flags: '-I$project/src', src_dirs: ['src'])
      app = link(exe_name: 'myapp',
                 dependencies: [objs, main_obj],
                 flags: '-L-M')
      bld = Build.new(app)

      expect(bld.to_json).to be_json_eql(
        '[{"type": "fixed",
           "command": {"type": "link", "flags": "-L-M"},
           "outputs": ["myapp"],
           "implicits": {"type": "fixed", "targets": []},
           "dependencies": {
               "type": "dynamic",
               "func": "targetConcat",
               "dependencies": [
                   {"type": "dynamic",
                    "func": "objectFiles",
                    "src_dirs": ["src"],
                    "exclude_dirs": [],
                    "src_files": [],
                    "exclude_files": [],
                    "flags": "-I$project/src",
                    "includes": [],
                    "string_imports": []},
                   {"type": "fixed",
                    "command": {"type": "shell",
                                "cmd": "dmd -I$project/src -c $in -of$out"},
                    "outputs": ["main.o"],
                    "dependencies": {"type": "fixed",
                                     "targets": [
                                         {"type": "fixed",
                                          "command": {},
                                          "outputs": ["src/main.d"],
                                          "dependencies": {
                                              "type": "fixed",
                                              "targets": []},
                                          "implicits": {
                                              "type": "fixed",
                                              "targets": []}}]},
                    "implicits": {
                        "type": "fixed",
                        "targets": []}}
               ]}}]')
    end
  end
end
