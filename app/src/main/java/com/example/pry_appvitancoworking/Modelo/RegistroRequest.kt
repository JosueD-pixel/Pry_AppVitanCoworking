package com.example.pry_appvitancoworking.Modelo

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class RegistroRequest(
    @SerialName("tipo") val tipo: String = "",          // "cliente" o "empresa"
    @SerialName("nombre") val nombre: String = "",
    @SerialName("ap") val ap: String = "",
    @SerialName("am") val am: String = "",
    @SerialName("correo") val correo: String = "",
    @SerialName("telefono") val telefono: String = "",
    @SerialName("calle") val calle: String = "",
    @SerialName("colonia") val colonia: String = "",
    @SerialName("cp") val cp: String = "",
    @SerialName("ciudad") val ciudad: String = "",
    @SerialName("contrasena") val contrasena: String = "",
    @SerialName("pregunta_seguridad") val pregunta_seguridad: String = "",
    @SerialName("respuesta_seguridad") val respuesta_seguridad: String = ""
)
