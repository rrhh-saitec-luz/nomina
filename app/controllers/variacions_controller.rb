# Frozen_string_literal: true

class VariacionsController < ApplicationController
  include Constantes
  
  def index; end

  def show
    @trab = Admon.find(params[:id])
    @presenter = TrabajadorPresenter.new(@trab)
  end

  def new
    @trab = Admon.find(params[:id])
    @variacion = Variacion.new
    @con = Listado.all
    @tipo_nomina = NominaTipo.all
    @estatus = estatus(@trab)
  end

  def nomina_espc_tipos
    @nomina_especifica = NominaEspecifica.where(tipo_nomina: params[:tipo_nomina])
    respond_to do |format|
      format.json { render json: @nomina_especifica }
    end
  end

  # POST /variacions
  def create
    @trab = Admon.find(params[:variacion][:id_trabajador])
    @variacion = Variacion.new(variacion_params_completos)
    @variacion.usuario = current_user&.nombre
    @variacion.status  = false # Control inicial (nace libre)

    # --- CERROJO DE SEGURIDAD: EVITAR DUPLICADOS AL CREAR ---
    if @variacion.accion == 'crear'
      concepto_duplicado = buscar_historico_vinculado

      if concepto_duplicado.present?
        @variacion.errors.add(:base, "El concepto #{@variacion.co_concepto} ya se encuentra registrado y activo para este trabajador. No puede crearlo dos veces.")
        render_new_with_errors and return
      end
    end
    # --------------------------------------------------------------

    # Invocamos tu método de transacción original
    transaccion(@trab, @variacion)
    
    render_new_with_errors unless @variacion.valid?
  rescue ActiveRecord::Rollback, ActiveRecord::RecordInvalid
    render_new_with_errors
  end

  # ¡AQUÍ ESTÁ EL MÉTODO QUE HACÍA FALTA! 
  def historico_variaciones
    @trabajador = Admon.find_by(
      ce_trabajador: params[:cedula], 
      co_ubicacion: params[:codigo],
      tipopersonal: params[:tipo]
    )
    @presenter = TrabajadorPresenter.new(@trabajador)
    @datos = HistoricoPago.where(
      CE_TRABAJADOR: params[:cedula],
      CO_UBICACION: params[:codigo],
      TIPOPERSONAL: params[:tipo]
    )
  end

  def destroy
    @elemento = Variacion.find(params[:id])
    @elemento.destroy
    redirect_to historico_variacions_path(cedula: @elemento.ce_trabajador, codigo: @elemento.co_ubicacion, tipo: @elemento.tipopersonal),
                notice: 'El elemento fue eliminado exitosamente.'
  end

  private

  def estatus(trabajador)
    trabajador.estatus.eql?('P') and 'P' or trabajador.tp
  end

  # Garantiza buscar con precisión en el Histórico usando los 4 campos compuestos de la variación actual
  def buscar_historico_vinculado
    HistoricoPago.find_by(
      CE_TRABAJADOR: @variacion.ce_trabajador,
      CO_UBICACION:  @variacion.co_ubicacion,
      TIPOPERSONAL:  @variacion.tipopersonal,
      CO_CONCEPTO:   @variacion.co_concepto
    )
  end


  # Tu método original corregido para procesar el borrado financiero real
  def ejecutar_eliminacion!
    variacion_previa = Variacion.find_by(
      ce_trabajador: @variacion.ce_trabajador,
      co_ubicacion:  @variacion.co_ubicacion, 
      tipopersonal:  @variacion.tipopersonal,
      co_concepto:   @variacion.co_concepto, 
      status:        false
    )

    # Definimos la acción de auditoría exacta
    @variacion.accion = variacion_previa.present? ? 'eliminar_abierto' : 'eliminar'
    @variacion.status = true # Queda asentado y cerrado el ciclo de este concepto

    # Buscamos el registro financiero real en HistoricoPago
    @historico_pago = HistoricoPago.find_by(
      CE_TRABAJADOR: @variacion.ce_trabajador,
      CO_UBICACION:  @variacion.co_ubicacion, 
      TIPOPERSONAL:  @variacion.tipopersonal,
      CO_CONCEPTO:   @variacion.co_concepto
    )

    # CORE: Si existe el registro financiero, lo destruimos
    if @historico_pago
      @historico_pago.destroy
    else
      @variacion.errors.add(:base, "El concepto seleccionado no existe en el Histórico de Pago.")
      raise ActiveRecord::Rollback
    end

    # Si hay una variación previa que quedó abierta por error, la cerramos también
    variacion_previa.update(status: true, accion: 'eliminar_abierto') if variacion_previa

    # Guardamos la bitácora actual de eliminación
    raise ActiveRecord::Rollback unless @variacion.save
  end

  # Tu método original de creación completado con los campos
  def ejecutar_creacion!
    @historico_pago = HistoricoPago.new(
      CE_TRABAJADOR:          @variacion.ce_trabajador,
      CO_UBICACION:           @variacion.co_ubicacion,
      TIPOPERSONAL:           @variacion.tipopersonal,
      CO_CONCEPTO:            @variacion.co_concepto,
      DESCRIPCION_TP:         @variacion.descripcion_tp,
      DESCRIPCION_CO:         @variacion.descripcion_co,
      IN_NOMINA:              @variacion.in_nomina,
      INDICPAGO:              @variacion.indic_pago,
      ESTATUS_CONCEPTO:       @variacion.estatus_concepto,
      FE_NOMINA:              @variacion.fe_nomina,
      FE_EFECTIVA:            @variacion.fe_efectiva,
      STATUS_DEDUCCION:       @variacion.estatus_deduccion,
      MO_CONCEP:              @variacion.mo_concepto,
      MO_SALDO:               @variacion.mo_saldo,
      STATUS_DEDUC:           @variacion.status_deduc,
      TIPO_NOMINA:            @variacion.tipo_nomina,
      TIPO_NOMINA_ESPECIFICA: @variacion.tipo_nomina_especifica,
      ANO:                    @variacion.ano,
      MES:                    @variacion.mes,
      INDICE_CONCEPTO:        @variacion.indice_concepto
    )

    raise ActiveRecord::Rollback unless @historico_pago.save && @variacion.save
  end

  # Administrador de la transacción
  def transaccion(trabajador, variacion)
    ActiveRecord::Base.transaction do
      if variacion.accion == 'eliminar'
        ejecutar_eliminacion!
        mensaje_exito = 'Concepto eliminado del histórico de pago y asentado en la bitácora.'
      else
        ejecutar_creacion!
        mensaje_exito = 'Variación registrada e historial de pago creado con éxito.'
      end

      # Redirección usando tu ruta correcta con "s"
      redirect_to historico_variacions_path(
                    cedula: trabajador.ce_trabajador, 
                    codigo: trabajador.co_ubicacion, 
                    tipo: trabajador.tipopersonal
                  ), notice: mensaje_exito
    end
  end

  def render_new_with_errors
    @con = Listado.all
    @tipo_nomina = NominaTipo.all
    @estatus = estatus(@trab)
    render :new
  end

  def variacion_params_completos
    params.require(:variacion).permit(
      :ce_trabajador, :co_ubicacion, :tipopersonal, :co_concepto, :accion,
      :id_trabajador, :descripcion_tp, :ce_beneficiario, :descripcion_co,
      :in_nomina, :indic_pago, :estatus_concepto, :fe_nomina, :fe_efectiva,
      :estatus_deduccion, :mo_concepto, :mo_saldo, :status_deduc,
      :tipo_nomina, :tipo_nomina_especifica, :ano, :mes, :indice_concepto
    )
  end
end
