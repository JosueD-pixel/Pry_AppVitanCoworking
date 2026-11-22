package com.example.pry_appvitancoworking.Presentador

import android.util.Patterns
import com.example.pry_appvitancoworking.Modelo.Cls_ModeloRecuperar
import com.example.pry_appvitancoworking.Vista.RecuperarActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

//A03 Recuperar cuenta (una sola pantalla):
//  paso 1 escribe el correo -> la API devuelve su pregunta
//  paso 2 contesta la pregunta y pone la contraseña nueva
class Cls_RecuperarPresentador(private val vista: RecuperarActivity) {
    private val modelo = Cls_ModeloRecuperar()
    private var correoEncontrado = ""   //el correo que ya se valido en el paso 1

    fun buscarCorreo(correo: String) {
        if (!Patterns.EMAIL_ADDRESS.matcher(correo).matches()) {
            vista.mostrarErrorCorreo("El correo no es valido")
            return
        }
        vista.mostrarCargando(true)
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val respuesta = withContext(Dispatchers.IO) {
                    modelo.obtenerPregunta(correo)
                }
                vista.mostrarCargando(false)
                if (respuesta.exito) {
                    correoEncontrado = correo
                    //muestra la parte de abajo con la pregunta y bloquea el correo
                    vista.mostrarPregunta(respuesta.pregunta_seguridad)
                } else {
                    //"No hay ninguna cuenta con ese correo" o "no tiene pregunta de seguridad"
                    vista.mostrarMensaje(respuesta.mensaje)
                }
            } catch (e: Exception) {
                vista.mostrarCargando(false)
                vista.mostrarMensaje("Revisa tu conexión a internet")
            }
        }
    }

    fun cambiarContrasena(respuesta: String, nueva: String, confirmar: String) {
        if (respuesta.isEmpty()) {
            vista.mostrarErrorCampo("respuesta", "Escribe tu respuesta")
            return
        }
        if (nueva.length < 8) {
            vista.mostrarErrorCampo("nueva", "Mínimo 8 caracteres")
            return
        }
        if (nueva != confirmar) {
            vista.mostrarErrorCampo("confirmar", "Las contraseñas no coinciden")
            return
        }
        vista.mostrarCargando(true)
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val resultado = withContext(Dispatchers.IO) {
                    modelo.recuperarContrasena(correoEncontrado, respuesta, nueva)
                }
                vista.mostrarCargando(false)
                vista.mostrarMensaje(resultado.mensaje)
                if (resultado.exito) {
                    vista.regresarAlLogin()
                }
            } catch (e: Exception) {
                vista.mostrarCargando(false)
                vista.mostrarMensaje("Revisa tu conexión a internet")
            }
        }
    }
}
