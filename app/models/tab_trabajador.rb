class TabTrabajador < ApplicationRecord
  validates :cedula, presence: true, uniqueness: true
end
