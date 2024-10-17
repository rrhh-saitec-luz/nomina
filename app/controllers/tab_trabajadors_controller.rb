class TabTrabajadorsController < ApplicationController
  DESCRIPCION_DE_ESTADOS = { 'A' => 'ACTIVO',
                             'F' => 'FALLECIDO',
                             'S' => 'SUSPENDIDO',
                             'R' => 'RETIRADO',
                             'P' => 'PENSIONADO',
                             'T' => 'PENSIONADO',
                             'C' => 'CONTRATADO' }.freeze

  DESCRIPCION_PRINCIPAL = { 'S' => 'SI', 'N' => 'NO' }.freeze

  def index
    @trabajadores = TabTrabajador.all
    @search_term = params[:q]
    @desc_estatus = DESCRIPCION_DE_ESTADOS

    if @search_term.present?
      @sidial = Admon.where('ce_trabajador::text ILIKE ?', "%#{@search_term}%").page(params[:page]).per(10)
    else
      @sidial = nil
    end
  end

  def new
    @nuevo = TabTrabajador.new
  end

  def show
    @trabajador = Admon.find(params[:id])
    @desc_estatus = DESCRIPCION_DE_ESTADOS
    @desc_principal = DESCRIPCION_PRINCIPAL
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
