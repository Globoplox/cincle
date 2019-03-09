require "lingo"

module Cincle

  VERSION = "0_2_0"
  
  macro included
    RULES = {} of Object => Object
    ROOT = {} of Symbol => Object
    NODES = {} of Symbol => Object

    macro rule(symbol, &block)
      \{% RULES[symbol.chars.join ""] = block %}
    end
    
    macro root(symbol)
      \{% ROOT[:value] = symbol.chars.join "" %} 
      _finished
    end

    macro node(symbol, &block)
      \{%
        node = NODES[symbol.chars.join ""] ? NODES[symbol.chars.join ""] : {:super => [] of Object}
        node[:block] = block
        NODES[symbol.chars.join ""] = node
      %}
    end

    macro onion(symbol, children, &block)
      module Unions::\{{symbol.camelcase.id}}
         \{{block.body}}
      end
      \{% for child in children %}
        \{%
          node = NODES[child.chars.join ""] ? NODES[child.chars.join ""] : {:super => [] of Object}
          node[:super].push "Unions::#{symbol.camelcase.id}"
          NODES[child.chars.join ""] = node
        %}
      \{% end %}
      node \{{symbol}} {
        def onion
          [\{{ (children.map { |child| "#{child.underscore.id}?".id } ).splat }}].compact.first.as(\{{ "Unions::#{symbol.camelcase.id}".id }})
        end
      }
      rule \{{symbol}} { \{{ ((children.map &.id).join "|").id }} }
    end

    macro _finished

      class Node

        def initialize(@nodes : Hash(Symbol, Array(Node)), @raw : String)
        end
        def raw
          @raw
        end
        \{% for name, block in RULES %}
          def \{{name.underscore.id}}?(index = 0)
            @nodes[:\{{name.underscore.id}}][index]?.as(Nodes::\{{name.camelcase.id}}?)
          end
          def \{{name.underscore.id}}(index = 0)
            @nodes[:\{{name.underscore.id}}][index].as(Nodes::\{{name.camelcase.id}})
          end
          \{%
            noun = name.underscore.chars.join ""
            consonants = ['z', 'r', 't', 'p', 'q', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'w', 'x', 'c', 'v', 'b', 'n']
            plural = if ["s", "ss", "sh", "ch", "x", "z", "o", "is"].any? { |suffix| noun.ends_with? suffix }
              "#{noun.id}es"
            elsif ["f", "fe"].any? { |suffix| noun.ends_with? suffix }
              "#{noun[0...(noun.size-1)].id}es"
            elsif noun.ends_with?("y") && consonants.includes? noun.chars[noun.size - 2]
              "#{noun[0...(noun.size-1)].id}ies"
            else
              "#{noun.id}s"
            end
          %}
          def \{{plural.id}}
            @nodes[:\{{name.underscore.id}}].map { |node| node.as(Nodes::\{{name.camelcase.id}}) }
          end
        \{% end %}
      end
      
      module Nodes
        \{% for name, block in RULES %}
          class \{{name.camelcase.id}} < Node
            \{% if (NODES[name] && NODES[name][:block]) %}
              \{{ NODES[name][:block].body }}
              \{% for interface in NODES[name][:super] %}
                include \{{interface.id}}
              \{% end %}
            \{% end %}
          end
        \{% end %}
      end

      class Parser < Lingo::Parser
        \{% for name, block in RULES %}
          rule(:\{{name.underscore.id}}) { (\{{block.body}}).named(:\{{name.underscore.id}}) }
        \{% end %}
          root(:\{{ROOT[:value].underscore.id}})
      end

      class Visitor < Lingo::Visitor

        @sizess = [] of Hash(Symbol, Int32)
        @stacks : Hash(Symbol, Array(Node)) = {} of Symbol => Array(Node)
        
        protected def push_states
          size = {} of Symbol => Int32
          @stacks.each { |(key, stack)| size[key] = stack.size }
          @sizess.push size
        end
        
        protected def pop_states(node_kind, stack, raw)
          sizes = @sizess.pop
          state = {} of Symbol => Array(Node)
          sizes.map do |(key, size)|
            diff = @stacks[key].size - size
            state[key] = @stacks[key].pop diff
          end
          node = node_kind.new state, raw
          stack.push node
        end

        \{% for name, block in RULES %}
          @stack_for_\{{name.underscore.id}} = [] of Node
          getter :stack_for_\{{name.underscore.id}}
          enter(:\{{name.underscore.id}}) { visitor.push_states }
          exit(:\{{name.underscore.id}}) { visitor.pop_states Nodes::\{{name.camelcase.id}}, visitor.stack_for_\{{name.underscore.id}}, node.full_value }
        \{% end %}
        def initialize
          \{% for name, block in RULES %}
            @stacks[:\{{name.underscore.id}}] = @stack_for_\{{name.underscore.id}}
          \{% end %}
        end
      end
      
      def self.parse(input)
        ast = Parser.new.parse(input)
        visitor = Visitor.new
        visitor.visit(ast)
        visitor.stack_for_\{{ROOT[:value].underscore.id}}[0].\{{ROOT[:value].underscore.id}}
      end

      \{% if flag? :debug_cincle %}
        \{% puts system "echo -e \"\e[36;1mBeginning of Cincle parser for \e[33;1m#{@type.name}\e[36;1m:\e[0m\"" %}
        \{% debug() %}
        \{% puts system "echo -e \"\e[36;1mEnd of Cincle parser for \e[33;1m#{@type.name}\e[36;1m.\e[0m\"" %}
      \{% end %}

    end
  end
end
