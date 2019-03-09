require "../src/cincle"

module Expression
  
 include Cincle

 # node :number {
 #   def val
 #     raw.to_f
 #   end
 # }

 # node :operator {
 #   def apply(operands) : Float64
 #     operands.reduce { |a,b|
       
 #     }
 #   end
 # }

 # node :operand {
 #   def val : Float64
 #     (groups + numbers).first.val
 #   end
 # }
 
 # node :operation {
 #   def val : Float64
 #     6.8#access the ordered operators and operands
 #   end
 # }

 # node :group {
 #   def val : Float64
 #     expression.val
 #   end
 # }

 # node :expression {
 #   def val : Float64
 #     case self
 #     when .group? then group.val
 #     when .operation? then operation.val
 #     else raise "Unsupported expression #{@nodes}"
 #     end
 #   end
 # }
 
 # rule :number { match(/\d+(\.\d+)?/) }
 # rule :plus { str("+") }
 # rule :minus { str("-") }
 # rule :time { str("*") }
 # rule :divide { str("/") }
 # rule :operand { group | number }
 # rule :operation { operand >> ((plus | minus | time | divide) >> operand).repeat(0) }
 # rule :group { str("(") >> expression >> str(")") }
 # rule :expression { operation | group }

 # rule(:hey) { str("") }
 # rule(:wife) { str("") }
 # rule(:hgy) { str("") }

 node :la {
   def val
     "A"
   end
 }
 rule :la { str "a" }

 node :lb {
   def val
     "B"
   end
 }
 rule :lb { str "b" }

 node :lc {
   def val
     "C"
   end
 }
 rule :lc { str "c" }

 rule :letter { str "" }

 onion :letter, [:la, :lb, :lc] {
   abstract def val
 }
 
 root :letter
end

puts Expression.parse(ARGV[0]).onion.val
