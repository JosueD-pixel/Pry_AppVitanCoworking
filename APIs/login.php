<?php
// Este es el api del login.php
header("Content-Type: application/json; charset=UTF-8");
require_once "config/conexion.php";

// Decodificar el cuerpo JSON enviado por Retrofit desde Android
$jsonInput = file_get_contents("php://input");
$data = json_decode($jsonInput, true);

$correo = isset($data['correo']) ? trim($data['correo']) : '';
$contrasena = isset($data['contrasena']) ? trim($data['contrasena']) : '';

if (empty($correo) || empty($contrasena)) {
    header("HTTP/1.1 400 Bad Request");
    echo json_encode([
        "exito" => false,
        "mensaje" => "Debe ingresar el correo y la contraseña"
    ]);
    exit;
}

try {
    // Busca al usuario por su correo y trae el nombre de su rol
    $stmt = $pdo->prepare("SELECT u.id_usuario, u.id_rol, r.rol, u.nombre, u.ap, u.correo, u.contrasena FROM usuarios u INNER JOIN roles r ON r.id_rol = u.id_rol WHERE u.correo = ?");
    $stmt->execute([$correo]);
    $usuario = $stmt->fetch();

    // La contraseña está guardada encriptada, por eso se compara con password_verify
    if ($usuario && password_verify($contrasena, $usuario['contrasena'])) {
        echo json_encode([
            "exito" => true,
            "mensaje" => "¡Bienvenido/a " . $usuario['nombre'] . "!",
            "id_usuario" => (int)$usuario['id_usuario'],
            "id_rol" => (int)$usuario['id_rol'],
            "rol" => $usuario['rol'],
            "nombre" => $usuario['nombre'],
            "ap" => $usuario['ap'],
            "correo" => $usuario['correo']
        ]);
    } else {
        echo json_encode([
            "exito" => false,
            "mensaje" => "Correo o contraseña incorrectos"
        ]);
    }
} catch (Exception $e) {
    header("HTTP/1.1 500 Internal Server Error");
    echo json_encode([
        "exito" => false,
        "mensaje" => "Error en el servidor: " . $e->getMessage()
    ]);
}
?>
