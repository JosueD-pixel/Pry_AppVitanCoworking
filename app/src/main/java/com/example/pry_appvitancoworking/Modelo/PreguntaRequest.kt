package com.example.pry_appvitancoworking.Modelo

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class PreguntaRequest(
    @SerialName("correo") val correo: String = ""
)
