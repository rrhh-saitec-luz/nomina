# Frozen_string_literal: true

# Clase que permite acceder a la base de datos y conectarse al esquema admon
class Pago < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :nomina_schema
end
