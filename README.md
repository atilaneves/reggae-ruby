Reggae-Ruby
=============
[![Build Status](https://travis-ci.org/atilaneves/reggae-ruby.png?branch=master)](https://travis-ci.org/atilaneves/reggae-ruby)


A Ruby interface / front-end to [the reggae meta-build system](https://github.org/atilaneves/reggae).


Installation
------------

    gem install reggae

The reason for a global install is that the `reggae` gem installs an executable script
called `reggae_json_build.rb` that is needed by the `reggae` D binary.

Usage
------------

This gem makes available a few classes and functions that allow the user to write
build descriptions in Ruby. It is essentially the same API as the D version but in
Ruby syntax. A simple C build could be written like this:

    require 'reggae'
    main_obj = Target.new('main.o', 'gcc -I$project/src -c $in -o $out', Target.new('src/main.c'))
    maths_obj = Target.new('maths.o', 'gcc -c $in -o $out', Target.new('src/maths.c'))
    app = Target.new('myapp', 'gcc -o $out $in', [main_obj, maths_obj])
    bld = Build.new(app)

This should be contained in a file named `reggaefile.rb` in the project's root directory.
Running the `reggae` D binary on that directory will produce a build with the requested backend
(ninja, make, etc.)

Most builds will probably not resort to low-level primitives as above. A better way to describe
that C build would be:

    require 'reggae'
    objs =  object_files(flags: '-I$project/src', src_dirs: ['src'])
    app = link(exe_name='app', dependencies=objs)
    bld = Build.new(app)


Please consult the [reggae documentation](https://github.com/atilaneves/reggae/tree/master/doc/index.md)
for more details.
