# Parlour

[![Build Status](https://travis-ci.org/AaronC81/parlour.svg?branch=master)](https://travis-ci.org/AaronC81/parlour)

Parlour is an RBI generator and merger for Sorbet. It consists of two key parts:

  - The generator, which outputs beautifully formatted RBI files, created using
    an intuitive DSL.

  - The plugin/build system, which allows multiple Parlour plugins to generate
    RBIs for the same codebase. These are combined automatically as much as 
    possible, but any other conflicts can be resolved manually through prompts.

## Why should I use this?

  - Parlour enables **much easier creation of RBI generators**, as formatting
    is all handled for you, and you don't need to write your own CLI.

  - You can **use many plugins together seamlessly**, running them all with a
    single command and consolidating all of their definitions into a single
    RBI output file.

## Usage

There aren't really any docs currently, so have a look around the code to find
any extra options you may need.

### Using just the generator

Here's a quick example of how you can generate an RBI:

```ruby
require 'parlour'

generator = Parlour::RbiGenerator.new
generator.root.create_module(name: 'A') do |a|
  a.create_class(name: 'Foo') do |foo|
    foo.create_method(name: 'add_two_integers', parameters: [
      Parlour::RbiGenerator::Parameter.new(name: 'a', type: 'Integer'),
      Parlour::RbiGenerator::Parameter.new(name: 'b', type: 'Integer')
    ], return_type: 'Integer')
  end

  a.create_class(name: 'Bar', superclass: 'Foo')
end

generator.rbi # => Our RBI as a string
```

This will generate the following RBI:

```ruby
module A
  class Foo
    sig { params(a: Integer, b: Integer).returns(Integer) }
    def add_two_integers(a, b); end
  end

  class Bar < Foo
  end
end
```

### Writing a plugin
Plugins are better than using the generator alone, as your plugin can be 
combined with others to produce larger RBIs without conflicts.

We could write the above example as a plugin like this:

```ruby
require 'parlour'

class MyPlugin < Parlour::Plugin
  def generate(root)
    root.create_module(name: 'A') do |a|
      a.create_class(name: 'Foo') do |foo|
        foo.create_method(name: 'add_two_integers', parameters: [
          Parlour::RbiGenerator::Parameter.new(name: 'a', type: 'Integer'),
          Parlour::RbiGenerator::Parameter.new(name: 'b', type: 'Integer')
        ], return_type: 'Integer')
      end

      a.create_class(name: 'Bar', superclass: 'Foo')
    end
  end
end
```

(Obviously, your plugin will probably examine a codebase somehow, to be more
useful!)

You can then run several plugins, combining their output and saving it into one
RBI file, using the command-line tool. The command line tool is configurated
using a `.parlour` YAML file. For example, if that code was in a file
called `plugin.rb`, then using this `.parlour` file and then running `parlour`
would save the RBI into `output.rbi`:

```yaml
output_file: output.rbi

relative_requires:
  - plugin.rb
  
plugins:
  MyPlugin: {}
```

The `{}` indicates that this plugin needs no extra configuration. If it did need
configuration, this could be specified like so:

```yaml
plugins:
  MyPlugin:
    foo: something
    bar: something else
```

You can also use plugins from gems. If that plugin was published as a gem called
`parlour-gem`:

```yaml
output_file: output.rbi

requires:
  - parlour-gem
  
plugins:
  MyPlugin: {}
```

The real power of this is the ability to use many plugins at once:

```yaml
output_file: output.rbi

requires:
  - gem1
  - gem2
  - gem3
  
plugins:
  Gem1::Plugin: {}
  Gem2::Plugin: {}
  Gem3::Plugin: {}
```

## Parlour Plugins

_Have you written an awesome Parlour plugin? Please submit a PR to add it to this list!_

  - [Sord](https://github.com/AaronC81/sord) - Generate RBIs from YARD documentation

## Parlour's Code Structure

### Overall Flow
```
                        STEP 1
                 All plugins mutate the
                 instance of RbiGenerator
                 They generate a tree
                 structure of RbiObjects

                 +--------+  +--------+
                 |Plugin 1|  |Plugin 2|
                 +----+---+  +----+---+         STEP 2
                      ^           ^        ConflictResolver
                      |           |        mutates the structure
+-------------------+ |           |        to fix conflicts
|                   | |           |
| One instance of   +-------------+        +----------------+
| RbiGenerator      +--------------------->+ConflictResolver|
|                   |                      +----------------+
+---------+---------+
          |
          |
          |          +-------+          STEP 3
          +--------->+ File  |    The final RBI is written
                     +-------+    to a file
```

### Generation
Everything that can generate lines of the RBI implements the 
`RbiGenerator::RbiObject` abstract class. The function `generate_rbi`
accepts the current indentation level and a set of formatting options.
(Each object is responsible for generating its own indentation; that is, the
lines generated by a child object should not then be indented by its parent.)

### Plugins
Plugins are automatically detected when they subclass `Plugin`. Plugins can then
be run by passing an array of them, along with an `RbiGenerator`, to
`Plugin.run_plugins`. Once done, the generator will be populated with a tree of
(possibly conflicting) `RbiObjects` - the conflict resolver (detailed below)
will clear up any conflicts.
  
### Conflict Resolution
This is a key part of the plugin/build system. The `ConflictResolver` takes
a namespace from the `RbiGenerator` and merges duplicate items in it together. 
This means that many plugins can generate their own signatures which are all 
bundled into one, conflict-free output RBI.

It is able to do the following merges automatically:

  - If many methods are identical, delete all but one.
  - If many classes are defined with the same name, merge their methods,
    includes and extends. (But only if they are all abstract or all not,
    and only if they don't define more than one superclass together.)
  - If many modules are defined with the same name, merge their methods,
    includes and extends. (But only if they are all interfaces or all not.)

If a merge can't be performed automatically, then the `#resolve_conflicts`
method takes a block. This block is passed all the conflicting objects, and one
should be selected and returned - all others will be deleted. (Alternatively,
the block can return nil, and all will be deleted.) This allows the CLI to 
prompt the user asking them what they'd like to do, in the case of conflicts
between each plugin's signatures which can't automatically be resolved.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AaronC81/parlour. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Parlour project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/AaronC81/parlour/blob/master/CODE_OF_CONDUCT.md).
