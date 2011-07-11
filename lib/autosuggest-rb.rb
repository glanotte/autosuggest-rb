require 'autosuggest/form_helper'
require 'autosuggest/controller_macros'

class ActionController::Base
  extend Autosuggest::ControllerMacros
end
