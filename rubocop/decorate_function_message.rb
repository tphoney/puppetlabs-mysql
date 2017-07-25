# frozen_string_literal: true
require 'pry'
module RuboCop
  module Cop
    module Lint
      class DecorateFunctionMessage < Cop

        def on_send(node)
          method_name = node.loc.selector.source
          return if !/raise|fail/.match(method_name)
          if method_name == "raise"
            receiver_node, method_name, *arg_nodes = *node
            if !arg_nodes.empty? && arg_nodes[0].type == :const && arg_nodes[1]
              how_bad_is_it(node, method_name, arg_nodes[1])
            end
          elsif method_name == "fail"
            receiver_node, method_name, *arg_nodes = *node
            if !arg_nodes.empty?
              how_bad_is_it(node, method_name, arg_nodes[0])
            end
          end
        end

        private

        def how_bad_is_it(node, method_name, message)
					if is_str(message)
					  add_offense(message, :expression, "'#{method_name}' should have a decorator around the message")
					elsif multiline_offense?(message)
						add_offense(message, :expression, "'#{method_name}' should not use a multi-line string")
					elsif concatination_offense?(message)
            add_offense(message, :expression, "'#{method_name}' should not use a concatenated string")
          elsif interpolation_offense?(message)
						add_offense(message, :expression, "'#{method_name}' interpolation is a sin")
					end
        end

        def is_str(message)
          message.str_type?
				end

        def is_dstr(message)
          message.dstr_type?
        end

				def is_send(message)
          message.type == :send
				end

        def multiline_offense?(message)
				found_mutliline = false
				strings_found = false
					message.children.each { |child| 
						if child == :/
							found_mutliline = true
					  elsif ( (!child.nil? && child.class != Symbol) && ( child.str_type? || child.dstr_type? ) )
						  strings_found = true
						end
					}
          found_mutliline && strings_found
			  end

        def concatination_offense?(message)
          found_concat = false
          strings_found = false
            message.children.each { |child|
              if child == :+
                found_concat = true
              elsif ( (!child.nil? && child.class != Symbol) && ( child.str_type? || child.dstr_type? ) )
                strings_found = true
              end
            }
            found_concat && strings_found
          end

				def interpolation_offense?(message)
          found_funct = false
          #binding.pry
          message.children.each { |child|
            if !child.nil? && child.class != Symbol
              if child.begin_type? || child.send_type?
                found_funct = true
              elsif child.dstr_type?
                found_funct = true if child.inspect.include?(":send") || child.inspect.include?(":begin")
              end
            end
          }
          found_funct
				end

        def autocorrect(node)
          if node.str_type?
            single_string_correct(node)
          else
            multiline_string_correct(node)
          end
        end

        def single_string_correct(node)
          ->(corrector) { corrector.insert_before(node.source_range , "_(")
          corrector.insert_after(node.source_range , ")") }
        end

        def multiline_string_correct(node)
          lambda do |corrector|
            corrector.remove(
              range_with_surrounding_space(node.loc.begin, :left)
            )
          end 
				end
			end
    end
  end
end
