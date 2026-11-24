package com.example.pry_appvitancoworking.Modelo

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Cls_Usuario(
    @SerialName("id_usuario") val id_usuario: Int = 0,
    @SerialName("id_rol") val id_rol: Int = 0,
    @SerialName("rol") val rol: String = "",
    @SerialName("nombre") val nombre: String = "",
    @SerialName("ap") val ap: String = "",
    @SerialName("am") val am: String? = null,
    @SerialName("cp") val cp: String? = null,
    @SerialName("calle") val calle: String? = null,
    @SerialName("ciudad") val ciudad: String? = null,
    @SerialName("colonia") val colonia: String? = null,
    @SerialName("correo") val correo: String = "",
    @SerialName("telefono") val telefono: String? = null,
    @SerialName("favorito") val favorito: Boolean = false
)
