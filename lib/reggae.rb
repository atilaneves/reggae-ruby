require 'json'

# Find the build object
module BuildFinder
  def self.get_build
    builds = []
    ObjectSpace.each_object(Build) { |x| builds << x }
    if builds.length != 1
      fail "Only one Build object may exist, found #{builds.length}"
    end
    builds[0]
  end
end

# Aggregates top-level targets
class Build
  def initialize(tgt)
    @targets = arrayify(tgt)
  end

  def to_json
    jsonify.to_json
  end

  def jsonify
    @targets.map { |t| t.jsonify }
  end
end

# A build target
class Target
  attr_reader :outputs, :command, :dependencies, :implicits

  def initialize(outputs, command = '', dependencies = [], implicits = [])
    @outputs = arrayify(outputs)
    @command = jsonifiable(command, ShellCommand)
    @dependencies = dependify(dependencies, FixedDependencies)
    @implicits = dependify(implicits, FixedDependencies)
  end

  def to_json
    jsonify.to_json
  end

  def jsonify
    { type: 'fixed',
      command: @command.jsonify,
      outputs: @outputs,
      dependencies: @dependencies.jsonify,
      implicits: @implicits.jsonify
    }
  end
end

# A shell command
class ShellCommand
  def initialize(cmd = '')
    @cmd = cmd
  end

  def jsonify
    @cmd == '' ? {} : { type: 'shell', cmd: @cmd }
  end
end

private def arrayify(arg)
  arg.class == Array ? arg : [arg]
end

private def jsonifiable(arg, klass)
  (arg.respond_to? :jsonify) ? arg : klass.new(arg)
end

private def dependify(arg, klass)
  (arg.is_a? Dependencies) ? arg : klass.new(arg)
end

# Equivalent to link in the D version
class LinkCommand
  def initialize(flags)
    @flags = flags
  end

  def jsonify
    { type: 'link', flags: @flags }
  end
end

def link(exe_name:, flags: '', dependencies: [], implicits: [])
  Target.new([exe_name], LinkCommand.new(flags), dependencies, implicits)
end

def object_files(src_dirs: [], exclude_dirs: [],
                 src_files: [], exclude_files: [],
                 flags: '',
                 includes: [], string_imports: [])
  DynamicDependencies.new('objectFiles',
                          { src_dirs: src_dirs,
                            exclude_dirs: exclude_dirs,
                            src_files: src_files,
                            exclude_files: exclude_files,
                            flags: flags,
                            includes: includes,
                            string_imports: string_imports })
end

class Dependencies
end

# A 'compile-time' known list of dependencies
class FixedDependencies < Dependencies
  def initialize(deps)
    @deps = arrayify(deps)
  end

  def jsonify
    { type: 'fixed', targets: @deps.map { |t| t.jsonify } }
  end
end

# A run-time determined list of dependencies
class DynamicDependencies < Dependencies
  def initialize(func_name, args)
    @func_name = func_name
    @args = args
  end

  def jsonify
    base = { type: 'dynamic', func: @func_name }
    base.merge(@args)
  end
end
