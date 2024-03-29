# Cincle

This is an old pet project. I keep it for the sake of it. 
I used it here [globoplox/dice](https://github.com/Globoplox/dice/tree/master).

Cincle is a layer added to the Lingo parser generator.
It aim to help to build meaningfull ast by altering the parser, generating a default visitor, and extensibles nodes for each rules.

## Installation

```yml
dependencies:
  cincle:
    github: globoplox/cincle
```

## Usage

```crystal
require "./cincle"

module Expression

 include Cincle

 node :number {
   def val
     raw.to_i
   end
 }

 node :operator {
   def apply(operands)
     operands.reduce { |a,b| plus? ? a + b : a - b }
   end
 }

 node :expression {
   def result
     operator.apply(numbers.map &.val)
   end
 }

 rule :number { match(/\d+/) }
 rule :plus { str("+") }
 rule :minus { str("-") }
 rule :operator { plus | minus }
 rule :expression { number >> operator >> number }

 root :expression
end

puts Expression.parse(ARGV[0]).result

```

Cincle rules are following the same pattern as Lingo (in fact, they are [Lingo rules](https://github.com/rmosolgo/lingo)).  
The `node` macro allow to define a custom body that will be inserted into the classes generated by Cincle.
The `root` macro must be called after all nodes and rules have been defined.

### Onion

The `onion` macro can be used to define union:
```crsytal
module Exemple
  include Cincle
  node :plus {
    def apply(a,b)
      a + b
    end
  }

  node :minus {
    def apply(a,b)
      a - b
    end
  }

  rule :plus { str "+" }
  rule :minus { str "-" }

  onion :operator, [:plus, :minus] {
    asbtract def apply
  }

  root :operator
end

Exemple.parse("-").apply(6,7)
```

### How it works

For each rules, a custom node class will be generated. Each node contain a `@nodes` attribute containing all subnodes that have been created during the parsing of the associated rule.
E.G. the `Expression` node will contain two `Numbers` node and an `Operator` node. Subnodes can be accessed from the `@nodes : Hash(Symbol,Array(Node))` attribute, or from the helpers method `<node_name>(index=0)`, `<node_name>?(index=0)` and `<plural_node_name>`.

The code generated by Cincle can be visualized by adding the `--define debug_cincle` to the crystal command.

## Todo

* Add a way to make node more typesafe, by removing accessor for nodes that cannot be subnodes of the current node. (E.G. `Number#minus` will raise at compile time, while `Operator#minus` wont).
* Add a true pluralizer, and/or allow defining customs pluralizers (trail: __DIR__ constant)

## Development

TODO: Write development instructions here

## Contributors

- [Globoplox](https://github.com/globoplox) Pierre Rousselle - creator, maintainer
