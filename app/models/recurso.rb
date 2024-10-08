class Recurso < ActiveRecord::Base 
  self.abstract_class = true
  establish_connection :admon_schema 
end
