<?php
// registro.php (Cliente - Crear cuenta tipo Cliente o Empresa)
header("Content-Type: application/json; charset=UTF-8");
require_once "config/conexion.php";

// Leer el cuerpo JSON enviado por Retrofit desde Android
$jsonInput = file_get_contents("php://input");
$data = json_decode($jsonInput, true);

// Sacar los datos
$tipo = isset($data['tipo']) ? trim($data['tipo']) : '';          // "cliente" o "empresa"
$nombre = isset($data['nombre']) ? trim($data['nombre']) : '';
$ap = isset($data['ap']) ? trim($data['ap']) : '';
$am = isset($data['am']) ? trim($data['am']) : '';
$correo = isset($data['correo']) ? trim($data['correo']) : '';
$telefono = isset($data['telefono']) ? trim($data['telefono']) : '';
$contrasena = isset($data['contrasena']) ? trim($data['contrasena']) : '';
$pregunta = isset($data['pregunta_seguridad']) ? trim($data['pregunta_seguridad']) : '';
$respuesta = isset($data['respuesta_seguridad']) ? trim($data['respuesta_seguridad']) : '';

// Valida si falta algo
// Si es empresa, los apellidos vienen desactivados en la app: se guardan vacíos (NULL)
if ($tipo === "empresa") {
    $ap = '';
    $am = '';
}

// Valida si falta algo (el apellido paterno solo se pide al cliente)
if (empty($tipo) || empty($nombre) || ($tipo === "cliente" && empty($ap)) || empty($correo) || empty($contrasena) || empty($pregunta) || empty($respuesta)) {
    header("HTTP/1.1 400 Bad Request");
    echo json_encode([
        "exito" => false,
        "mensaje" => "Debe ingresar tipo de cuenta, nombre, apellido (cliente), correo, contraseña y pregunta de seguridad con su respuesta"
    ]);
    exit;
}

// El tipo de cuenta dice el rol: 2 = cliente, 3 = empresa
if ($tipo === "cliente") {
    $id_rol = 2;
} elseif ($tipo === "empresa") {
    $id_rol = 3;
} else {
    echo json_encode(["exito" => false, "mensaje" => "El tipo de cuenta debe ser cliente o empresa"]);
    exit;
}

if (!filter_var($correo, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(["exito" => false, "mensaje" => "El correo no es valido"]);
    exit;
}

// El telefono es opcional, pero si viene debe tener 10 digitos (preg_match revisa el patron)
if (!empty($telefono) && !preg_match('/^[0-9]{10}$/', $telefono)) {
    echo json_encode(["exito" => false, "mensaje" => "El telefono debe tener 10 digitos"]);
    exit;
}

if (strlen($contrasena) < 8) {
    echo json_encode(["exito" => false, "mensaje" => "La contraseña debe tener al menos 8 caracteres"]);
    exit;
}

try {
    // Valida si el correo ya esta registrado
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM usuarios WHERE correo = ?");
    $stmt->execute([$correo]);
    if ((int)$stmt->fetchColumn() > 0) {
        echo json_encode(["exito" => false, "mensaje" => "Ese correo ya tiene una cuenta"]);
        exit;
    }

    // Insertar el usuario con la contraseña encriptada
    // La respuesta se guarda cifrada y en minusculas, para que "Firulais" y "firulais" cuenten igual
    $stmt = $pdo->prepare("INSERT INTO usuarios (id_rol, nombre, ap, am, correo, telefono, contrasena, pregunta_seguridad, respuesta_seguridad) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$id_rol, $nombre, $ap !== '' ? $ap : null, $am !== '' ? $am : null, $correo, $telefono !== '' ? $telefono : null, password_hash($contrasena, PASSWORD_DEFAULT), $pregunta, password_hash(mb_strtolower($respuesta), PASSWORD_DEFAULT)]);

    echo json_encode([
        "exito" => true,
        "mensaje" => "¡Cuenta creada! Ya puedes iniciar sesión",
        "id_usuario" => (int)$pdo->lastInsertId()
    ]);
} catch (Exception $e) {
    header("HTTP/1.1 500 Internal Server Error");
    echo json_encode([
        "exito" => false,
        "mensaje" => "Error en el servidor: " . $e->getMessage()
    ]);
}
?>
