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
    @dependencies = arrayify(dependencies)
    @implicits = arrayify(implicits)
  end

  def to_json
    jsonify.to_json
  end

  def jsonify
    { type: 'fixed',
      command: @command.jsonify,
      outputs: @outputs,
      dependencies: { type: 'fixed',
                      targets: @dependencies.map { |t| t.jsonify } },
      implicits: { type: 'fixed',
                   targets: @implicits.map { |t| t.jsonify } }
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

def arrayify(arg)
  arg.class == Array ? arg : [arg]
end

private def jsonifiable(arg, klass)
  (arg.respond_to? :jsonify) ? arg : klass.new(arg)
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
