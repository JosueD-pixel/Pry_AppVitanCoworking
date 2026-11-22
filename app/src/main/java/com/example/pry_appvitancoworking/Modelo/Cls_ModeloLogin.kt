package com.example.pry_appvitancoworking.Modelo

import com.example.pry_appvitancoworking.Redes.RetrofitCliente

class Cls_ModeloLogin {
    suspend fun iniciarSesion(correo: String, contrasena: String): LoginResponse {
        val request = LoginRequest(correo = correo, contrasena = contrasena)
        return RetrofitCliente.apiService.iniciarSesion(request)
    }
}
