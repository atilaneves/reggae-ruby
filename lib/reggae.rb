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
  end
end

# A build target
class Target
  def initialize(outputs, command = '', dependencies = [], implicits = [])
    @outputs = arrayify(outputs)
    @command = command
    @dependencies = arrayify(dependencies)
    @implicits = arrayify(implicits)
  end

  def to_json
    { type: 'fixed',
      command: {},
      outputs: @outputs,
      dependencies: { type: 'fixed', targets: @dependencies },
      implicits: { type: 'fixed', targets: @implicits }
    }.to_json
  end
end

def arrayify(arg)
  arg.class == Array ? arg : [arg]
end
