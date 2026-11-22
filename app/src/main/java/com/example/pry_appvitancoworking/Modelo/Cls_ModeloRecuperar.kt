package com.example.pry_appvitancoworking.Modelo

import com.example.pry_appvitancoworking.Redes.RetrofitCliente

class Cls_ModeloRecuperar {
    // Paso 1: con el correo trae la pregunta de seguridad
    suspend fun obtenerPregunta(correo: String): PreguntaResponse {
        return RetrofitCliente.apiService.obtenerPregunta(PreguntaRequest(correo = correo))
    }

    // Paso 2: si la respuesta es correcta guarda la contraseña nueva
    suspend fun recuperarContrasena(correo: String, respuesta: String, contrasenaNueva: String): RecuperarResponse {
        val request = RecuperarRequest(correo = correo, respuesta_seguridad = respuesta, contrasena_nueva = contrasenaNueva)
        return RetrofitCliente.apiService.recuperarContrasena(request)
    }
}
