package com.example.pry_appvitancoworking.Vista

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.pry_appvitancoworking.Presentador.Cls_RecuperarPresentador
import com.example.pry_appvitancoworking.R
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout

//A03 Recuperar cuenta: una sola pantalla en 2 pasos
class RecuperarActivity : AppCompatActivity() {
    private lateinit var presentador: Cls_RecuperarPresentador
    private lateinit var tilCorreo: TextInputLayout
    private lateinit var tilRespuesta: TextInputLayout
    private lateinit var tilNueva: TextInputLayout
    private lateinit var tilConfirmar: TextInputLayout
    private lateinit var etCorreo: TextInputEditText
    private lateinit var etRespuesta: TextInputEditText
    private lateinit var etNueva: TextInputEditText
    private lateinit var etConfirmar: TextInputEditText
    private lateinit var btnBuscar: Button
    private lateinit var btnCambiar: Button
    private lateinit var llPaso1: LinearLayout
    private lateinit var llPaso2: LinearLayout
    private lateinit var txtPaso1: TextView
    private lateinit var txtPaso2: TextView
    private lateinit var txtCorreoElegido: TextView
    private lateinit var txtPregunta: TextView
    private lateinit var txtIniciarSesion: TextView
    private lateinit var btnRegresar: ImageButton
    private lateinit var pbCargando: ProgressBar

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_recuperar)
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }
        //enlazar componentes XML
        tilCorreo = findViewById(R.id.tilCorreo)
        tilRespuesta = findViewById(R.id.tilRespuesta)
        tilNueva = findViewById(R.id.tilNueva)
        tilConfirmar = findViewById(R.id.tilConfirmar)
        etCorreo = findViewById(R.id.etCorreo)
        etRespuesta = findViewById(R.id.etRespuesta)
        etNueva = findViewById(R.id.etNueva)
        etConfirmar = findViewById(R.id.etConfirmar)
        btnBuscar = findViewById(R.id.btnBuscar)
        btnCambiar = findViewById(R.id.btnCambiar)
        llPaso1 = findViewById(R.id.llPaso1)
        llPaso2 = findViewById(R.id.llPaso2)
        txtPaso1 = findViewById(R.id.txtPaso1)
        txtPaso2 = findViewById(R.id.txtPaso2)
        txtCorreoElegido = findViewById(R.id.txtCorreoElegido)
        txtPregunta = findViewById(R.id.txtPregunta)
        txtIniciarSesion = findViewById(R.id.txtIniciarSesion)
        btnRegresar = findViewById(R.id.btnRegresar)
        pbCargando = findViewById(R.id.pbCargando)

        //inicializar presentador
        presentador = Cls_RecuperarPresentador(this)

        btnBuscar.setOnClickListener(this::ejecutarBuscar)
        btnCambiar.setOnClickListener(this::ejecutarCambiar)
        txtIniciarSesion.setOnClickListener { finish() }
        btnRegresar.setOnClickListener { finish() }
    }

    //Paso 1
    fun ejecutarBuscar(v: View) {
        tilCorreo.error = null
        presentador.buscarCorreo(etCorreo.text.toString().trim())
    }

    //Paso 2
    fun ejecutarCambiar(v: View) {
        tilRespuesta.error = null
        tilNueva.error = null
        tilConfirmar.error = null
        presentador.cambiarContrasena(
            etRespuesta.text.toString().trim(),
            etNueva.text.toString(),
            etConfirmar.text.toString()
        )
    }

    //el correo existe: se oculta el paso 1 y aparece la pregunta con los campos de abajo (paso 2)
    fun mostrarPregunta(pregunta: String) {
        txtPregunta.text = pregunta
        txtCorreoElegido.text = etCorreo.text.toString().trim()
        llPaso1.visibility = View.GONE
        llPaso2.visibility = View.VISIBLE
        //el paso 1 queda con palomita y el paso 2 se marca como actual
        txtPaso1.text = getString(R.string.txtPaso1Listo)
        txtPaso1.setCompoundDrawablesRelativeWithIntrinsicBounds(R.drawable.ic_paso_listo, 0, 0, 0)
        txtPaso1.setBackgroundResource(R.drawable.bg_acceso_paso_inactivo)
        txtPaso2.setBackgroundResource(R.drawable.bg_acceso_paso_activo)
        txtPaso2.setTextColor(ContextCompat.getColor(this, R.color.accesoAzul))
    }

    fun mostrarErrorCorreo(mensaje: String) {
        tilCorreo.error = mensaje
    }

    fun mostrarErrorCampo(campo: String, mensaje: String) {
        when (campo) {
            "respuesta" -> tilRespuesta.error = mensaje
            "nueva" -> tilNueva.error = mensaje
            "confirmar" -> tilConfirmar.error = mensaje
        }
    }

    fun mostrarCargando(cargando: Boolean) {
        pbCargando.visibility = if (cargando) View.VISIBLE else View.GONE
        btnBuscar.isEnabled = !cargando
        btnCambiar.isEnabled = !cargando
    }

    fun mostrarMensaje(mensaje: String) {
        Toast.makeText(this, mensaje, Toast.LENGTH_LONG).show()
    }

    //contraseña cambiada: regresa a Iniciar sesion
    fun regresarAlLogin() {
        finish()
    }
}
