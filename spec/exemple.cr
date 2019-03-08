require "../src/cincle"

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
 rule(:hey) { str("") }
 
 root :expression
end

puts Expression.parse(ARGV[0]).result
