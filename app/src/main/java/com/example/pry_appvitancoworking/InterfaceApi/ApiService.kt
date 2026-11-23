package com.example.pry_appvitancoworking.InterfaceApi

import com.example.pry_appvitancoworking.Modelo.LoginRequest
import com.example.pry_appvitancoworking.Modelo.LoginResponse
import com.example.pry_appvitancoworking.Modelo.PreguntaRequest
import com.example.pry_appvitancoworking.Modelo.PreguntaResponse
import com.example.pry_appvitancoworking.Modelo.RecuperarRequest
import com.example.pry_appvitancoworking.Modelo.RecuperarResponse
import com.example.pry_appvitancoworking.Modelo.RegistroRequest
import com.example.pry_appvitancoworking.Modelo.RegistroResponse
import com.example.pry_appvitancoworking.Modelo.dataCancelacion
import com.example.pry_appvitancoworking.Modelo.dataSala
import com.example.pry_appvitancoworking.Modelo.dataTipoSala

import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query

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

    // Nathan - Salas

    //Lista de tipos de sala para el Spinner
    @GET("listar_tipos_sala.php")
    suspend fun obtenerTiposSala(): List<dataTipoSala>

    //Salas de un tipo (id_tipo_sala = 0 trae todas)
    @GET("listar_salas.php")
    suspend fun obtenerSalas(@Query("id_tipo_sala") id_tipo_sala: Int): List<dataSala>

    //Lista de cancelaciones
    @GET("consultar_cancelaciones.php")
    suspend fun obtenerCancelaciones(): List<dataCancelacion>
    // ... (abajo siguen las funciones de Ángel y Christian)
}
