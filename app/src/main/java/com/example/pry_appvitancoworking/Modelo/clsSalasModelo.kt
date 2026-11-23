package com.example.pry_appvitancoworking.Modelo

import com.example.pry_appvitancoworking.Redes.RetrofitCliente

class clsSalasModelo {
    suspend fun obtenerTiposSala(): List<dataTipoSala> {
        return RetrofitCliente.apiService.obtenerTiposSala()
    }
    suspend fun obtenerSalas(id_tipo_sala: Int): List<dataSala> {
        return RetrofitCliente.apiService.obtenerSalas(id_tipo_sala)
    }
}