class ApplicationRecord < ActiveRecord::Base
  include HasMoreSecureToken

  primary_abstract_class
end
