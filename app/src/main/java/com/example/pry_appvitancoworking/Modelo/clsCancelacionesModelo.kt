package com.example.pry_appvitancoworking.Modelo

import com.example.pry_appvitancoworking.Redes.RetrofitCliente


class clsCancelacionesModelo {
    suspend fun obtenerCancelaciones(): List<dataCancelacion> {
        return RetrofitCliente.apiService.obtenerCancelaciones()
    }
}