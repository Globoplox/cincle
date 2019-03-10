require "../src/cincle"

module Exemple::Onion
  
 include Cincle

 node :la {
   def val
     "A"
   end
 }
 rule :la { str "a" }

 node :lb {
   def val
     "hello"
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

# Calls to Nodes::Letter are delegated to the onion:
puts Exemple::Onion.parse(ARGV[0]).val
# Is the same as:
puts Exemple::Onion.parse(ARGV[0]).onion.val
