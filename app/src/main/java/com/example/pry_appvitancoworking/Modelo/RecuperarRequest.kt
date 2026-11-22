package com.example.pry_appvitancoworking.Modelo

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class RecuperarRequest(
    @SerialName("correo") val correo: String = "",
    @SerialName("respuesta_seguridad") val respuesta_seguridad: String = "",
    @SerialName("contrasena_nueva") val contrasena_nueva: String = ""
)
