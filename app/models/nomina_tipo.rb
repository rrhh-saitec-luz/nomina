# Frozen_string_literal: true

# clase que permite obtener conceptos en la nomina
class NominaTipo < Pago
  self.table_name = 'nomina.tab_tipo_nomina'
  has_many :nomina_especifica
end
