module Helpers

  # For each cookbook, rename module to MyCookbookName in this file, and in _test.rb files
  module MinitestHandler
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources
  end

  # Write helper functions here

   module BaseHandler
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources
  end

end
