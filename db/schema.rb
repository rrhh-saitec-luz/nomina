# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_13_150948) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nueva_hist_detalle_pagos", force: :cascade do |t|
    t.integer "CE_TRABAJADOR"
    t.string "CO_UBICACION"
    t.string "TIPOPERSONAL"
    t.string "DESCRIPCION_TP"
    t.string "CE_BENEFICIARIO"
    t.string "CO_CONCEPTO"
    t.string "DESCRIPCION_CO"
    t.string "IN_NOMINA"
    t.string "INDICPAGO"
    t.string "ESTATUS_CONCEPTO"
    t.date "FE_NOMINA"
    t.date "FE_EFECTIVA"
    t.decimal "STATUS_DEDUCCION"
    t.decimal "MO_CONCEP"
    t.decimal "MO_SALDO"
    t.string "STATUS_DEDUC"
    t.integer "TIPO_NOMINA"
    t.integer "TIPO_NOMINA_ESPECIFICA"
    t.integer "ANO"
    t.integer "MES"
    t.string "INDICE_CONCEPTO"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "personals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tab_trabajadors", force: :cascade do |t|
    t.integer "cedula", null: false
    t.string "nombre1", null: false
    t.string "nombre2", default: ""
    t.string "apellido1", null: false
    t.string "apellido2", default: ""
    t.date "fecha_de_nac", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cedula"], name: "index_tab_trabajadors_on_cedula", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "nombre", default: "", null: false
    t.string "apellido", default: "", null: false
    t.string "cedula", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "variacions", force: :cascade do |t|
    t.integer "ce_trabajador"
    t.string "co_ubicacion"
    t.string "tipopersonal"
    t.string "descripcion_tp"
    t.integer "ce_beneficiario"
    t.string "co_concepto"
    t.string "descripcion_co"
    t.string "in_nomina"
    t.string "inicpago"
    t.string "estatus_concepto"
    t.date "fe_nomina"
    t.date "fe_efectiva"
    t.date "fe_efectiva_real"
    t.decimal "estatus_deduccion"
    t.decimal "mo_concepto"
    t.decimal "mo_saldo"
    t.decimal "status_deduc"
    t.integer "tipo_nomina"
    t.integer "tipo_nomina_especifica"
    t.integer "ano"
    t.integer "mes"
    t.string "indice_concepto"
    t.string "usuario"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
