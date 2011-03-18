{exec, spawn} = require 'child_process'

print = (data) -> console.log data.toString().trim()

task 'build', 'Compile riak-js Coffeescript source to Javascript', ->
  exec 'mkdir -p lib && coffee -c -o lib src'
  
task 'dev', 'Continuous compilation', ->
  coffee = spawn 'coffee', '-wc --bare -o lib src'.split(' ')

  coffee.stdout.on 'data', print
  coffee.stderr.on 'data', print