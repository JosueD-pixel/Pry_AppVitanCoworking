<?php
// obtener_pregunta.php (Recuperar cuenta, paso 1: con el correo regresa su pregunta de seguridad)
header("Content-Type: application/json; charset=UTF-8");
require_once "config/conexion.php";

$jsonInput = file_get_contents("php://input");
$data = json_decode($jsonInput, true);

$correo = isset($data['correo']) ? trim($data['correo']) : '';

if (empty($correo)) {
    header("HTTP/1.1 400 Bad Request");
    echo json_encode(["exito" => false, "mensaje" => "Debe ingresar su correo"]);
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT pregunta_seguridad FROM usuarios WHERE correo = ?");
    $stmt->execute([$correo]);
    $usuario = $stmt->fetch();

    if (!$usuario) {
        echo json_encode(["exito" => false, "mensaje" => "No hay ninguna cuenta con ese correo"]);
    } elseif (empty($usuario['pregunta_seguridad'])) {
        echo json_encode(["exito" => false, "mensaje" => "Esta cuenta no tiene pregunta de seguridad, pide ayuda al administrador"]);
    } else {
        echo json_encode([
            "exito" => true,
            "mensaje" => "Contesta tu pregunta de seguridad",
            "pregunta_seguridad" => $usuario['pregunta_seguridad']
        ]);
    }
} catch (Exception $e) {
    header("HTTP/1.1 500 Internal Server Error");
    echo json_encode(["exito" => false, "mensaje" => "Error en el servidor: " . $e->getMessage()]);
}
?>
