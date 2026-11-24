package com.example.pry_appvitancoworking.Modelo

import com.example.pry_appvitancoworking.Redes.RetrofitCliente

class Cls_ModeloAdminUsuarios {

    // id_rol: 1 administrador, 2 cliente, 3 empresa o 0 para todos
    suspend fun obtenerUsuarios(id_rol: Int): List<Cls_Usuario> {
        return RetrofitCliente.apiService.listarUsuarios(id_rol)
    }
}
