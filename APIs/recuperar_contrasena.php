<?php
// recuperar_contrasena.php (Recuperar cuenta, paso 2: si la respuesta es correcta guarda la contraseña nueva)
header("Content-Type: application/json; charset=UTF-8");
require_once "config/conexion.php";

$jsonInput = file_get_contents("php://input");
$data = json_decode($jsonInput, true);

$correo = isset($data['correo']) ? trim($data['correo']) : '';
$respuesta = isset($data['respuesta_seguridad']) ? trim($data['respuesta_seguridad']) : '';
$nueva = isset($data['contrasena_nueva']) ? trim($data['contrasena_nueva']) : '';

if (empty($correo) || empty($respuesta) || empty($nueva)) {
    header("HTTP/1.1 400 Bad Request");
    echo json_encode(["exito" => false, "mensaje" => "Debe ingresar correo, respuesta y contraseña nueva"]);
    exit;
}

if (strlen($nueva) < 8) {
    echo json_encode(["exito" => false, "mensaje" => "La contraseña debe tener al menos 8 caracteres"]);
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT id_usuario, respuesta_seguridad FROM usuarios WHERE correo = ?");
    $stmt->execute([$correo]);
    $usuario = $stmt->fetch();

    // La respuesta se guardo cifrada y en minusculas, por eso se compara igual que la contraseña
    if (!$usuario || empty($usuario['respuesta_seguridad']) || !password_verify(mb_strtolower($respuesta), $usuario['respuesta_seguridad'])) {
        echo json_encode(["exito" => false, "mensaje" => "La respuesta no es correcta"]);
        exit;
    }

    $stmt = $pdo->prepare("UPDATE usuarios SET contrasena = ? WHERE id_usuario = ?");
    $stmt->execute([password_hash($nueva, PASSWORD_DEFAULT), $usuario['id_usuario']]);

    echo json_encode(["exito" => true, "mensaje" => "Contraseña actualizada, ya puedes iniciar sesión"]);
} catch (Exception $e) {
    header("HTTP/1.1 500 Internal Server Error");
    echo json_encode(["exito" => false, "mensaje" => "Error en el servidor: " . $e->getMessage()]);
}
?>
