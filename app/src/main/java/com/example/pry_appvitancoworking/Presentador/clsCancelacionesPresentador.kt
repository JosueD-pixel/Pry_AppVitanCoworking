package com.example.pry_appvitancoworking.Presentador

import com.example.pry_appvitancoworking.Modelo.clsCancelacionesModelo
import com.example.pry_appvitancoworking.Vista.CancelacionesActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

//D03 Cancelaciones (administrador): solo consulta
class clsCancelacionesPresentador(private val vista: CancelacionesActivity) {
    private val modelo = clsCancelacionesModelo()

    fun cargarCancelaciones() {
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val cancelaciones = withContext(Dispatchers.IO) {
                    modelo.obtenerCancelaciones()
                }
                if (cancelaciones.isEmpty()) {
                    vista.mostrarSinCancelaciones()
                } else {
                    vista.mostrarCancelaciones(cancelaciones)
                }
            } catch (e: Exception) {
                vista.mostrarError("Revisa tu conexión a internet")
            }
        }
    }
}