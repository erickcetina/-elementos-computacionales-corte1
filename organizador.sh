#!/bin/bash
#
# organizador.sh
# Organiza los archivos .txt de un directorio: los copia a una carpeta de
# backup con fecha, renombrándolos, y genera un resumen.log con el listado
# y el conteo total.
#
# Uso: ./organizador.sh /ruta/al/directorio

# Se recibe el directorio como argumento ($1)
DIRECTORIO="$1"

# Verificar que se haya pasado un argumento
if [ -z "$DIRECTORIO" ]; then
    echo "Error: debes indicar un directorio como argumento."
    echo "Uso: $0 /ruta/al/directorio"
    exit 1
fi

# Verificar que el directorio exista, si no, termina con un mensaje de error
if [ ! -d "$DIRECTORIO" ]; then
    echo "Error: el directorio '$DIRECTORIO' no existe."
    exit 1
fi

# Fecha actual en formato YYYY-MM-DD
FECHA=$(date +%Y-%m-%d)

# Contar los archivos con extensión .txt
CONTADOR=0
for archivo in "$DIRECTORIO"/*.txt; do
    # Si no hay ningún .txt, el glob no se expande y queda el patrón literal
    [ -e "$archivo" ] || continue
    CONTADOR=$((CONTADOR + 1))
done

if [ "$CONTADOR" -eq 0 ]; then
    echo "No se encontraron archivos .txt en '$DIRECTORIO'."
    exit 0
fi

# Crear la subcarpeta backup_YYYY-MM-DD
CARPETA_BACKUP="$DIRECTORIO/backup_$FECHA"
mkdir -p "$CARPETA_BACKUP"

# Copiar todos los .txt a esa carpeta, añadiendo la fecha al inicio del nombre
#    y va guardando el listado para el resumen
LISTADO=""
for archivo in "$DIRECTORIO"/*.txt; do
    [ -e "$archivo" ] || continue
    NOMBRE_BASE=$(basename "$archivo")
    NUEVO_NOMBRE="${FECHA}_${NOMBRE_BASE}"
    cp "$archivo" "$CARPETA_BACKUP/$NUEVO_NOMBRE"
    LISTADO="$LISTADO$NUEVO_NOMBRE"$'\n'
done

# Generar resumen.log dentro de la subcarpeta con el listado y el conteo total
{
    echo "Resumen de backup - $FECHA"
    echo "Directorio original: $DIRECTORIO"
    echo "-----------------------------------"
    echo "Archivos copiados:"
    echo "$LISTADO"
    echo "-----------------------------------"
    echo "Total de archivos .txt copiados: $CONTADOR"
} > "$CARPETA_BACKUP/resumen.log"

echo "Proceso completado. Se copiaron $CONTADOR archivo(s) .txt a: $CARPETA_BACKUP"
echo "Resumen generado en: $CARPETA_BACKUP/resumen.log"
