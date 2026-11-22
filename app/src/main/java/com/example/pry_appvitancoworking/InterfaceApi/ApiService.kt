package com.example.pry_appvitancoworking.InterfaceApi

import com.example.pry_appvitancoworking.Modelo.LoginRequest
import com.example.pry_appvitancoworking.Modelo.LoginResponse
import com.example.pry_appvitancoworking.Modelo.PreguntaRequest
import com.example.pry_appvitancoworking.Modelo.PreguntaResponse
import com.example.pry_appvitancoworking.Modelo.RecuperarRequest
import com.example.pry_appvitancoworking.Modelo.RecuperarResponse
import com.example.pry_appvitancoworking.Modelo.RegistroRequest
import com.example.pry_appvitancoworking.Modelo.RegistroResponse

import retrofit2.http.Body
import retrofit2.http.POST

interface ApiService {

    //Angel - Acceso
    //Iniciar sesion (cliente, empresa y administrador)
    @POST("login.php")
    suspend fun iniciarSesion(@Body request: LoginRequest): LoginResponse

    //Crear cuenta tipo cliente o empresa
    @POST("registro.php")
    suspend fun crearCuenta(@Body request: RegistroRequest): RegistroResponse

    //Recuperar cuenta: 1) traer la pregunta de seguridad del correo
    @POST("obtener_pregunta.php")
    suspend fun obtenerPregunta(@Body request: PreguntaRequest): PreguntaResponse

    //Recuperar cuenta: 2) contestar y poner la contraseña nueva
    @POST("recuperar_contrasena.php")
    suspend fun recuperarContrasena(@Body request: RecuperarRequest): RecuperarResponse
}
