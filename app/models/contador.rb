class Contador < ApplicationRecord
  validates :nombre, presence: true, uniqueness: true

  def self.valor_de(nombre_flujo)
    find_by(nombre: nombre_flujo)
  end
end
