class TabTrabajadorsController < ApplicationController
  def index
    @trabajadores = TabTrabajador.all
  end

  def new
    @nuevo = TabTrabajador.new
  end

  def show
  end

  def create
    @nuevo = TabTrabajador.new(nuevo_ingreso_params)
    
    if @nuevo.save
      redirect_to tab_trabajadors_index_path
    else
      redirect_to tab_trabajadors_new_path
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def nuevo_ingreso_params
    params.permit(:cedula, :nombre1, :nombre2, :apellido1, :apellido2, :fecha_de_nac)
  end


end
