# Method 1: Include
# import "webserver.pp"
# include webserver

# Method 2: Specify parameter value
# import "webserver.pp"
# class { "webserver":
#   message => "Hi there!",
# }

# Method 3: Default parameter value
import "webserver.pp"
class { "webserver": }