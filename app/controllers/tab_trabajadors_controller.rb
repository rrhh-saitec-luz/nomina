class TabTrabajadorsController < ApplicationController
  def index
    @trabajadores = TabTrabajador.all
    @search_term = params[:q]

    if @search_term.present?
      @sidial = Admon.where('nombres ILIKE ? OR ce_trabajador::text ILIKE ?', "%#{@search_term}%", "%#{@search_term}%").page(params[:page]).per(10)
    else
      @sidial = Admon.page(params[:page]).per(10)
    end
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
      render :new, status: :unprocessable_entity
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
