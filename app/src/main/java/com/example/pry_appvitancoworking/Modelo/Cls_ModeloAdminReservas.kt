package com.example.pry_appvitancoworking.Modelo

import com.example.pry_appvitancoworking.Redes.RetrofitCliente

class Cls_ModeloAdminReservas {

    // estado: "pendiente", "confirmada", "finalizada", "cancelada" o "" para todas
    suspend fun obtenerReservas(estado: String): List<Cls_Reserva> {
        return RetrofitCliente.apiService.consultarReservas(estado)
    }
}
