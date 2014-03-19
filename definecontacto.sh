#!/bin/bash
 
#definecontacto.sh
# Script para definir contactos temporales de Icinga o Nagios.
#
#Dependencias:
# dialog
# sudo  
 
#Habilito la expansión de alias
shopt -s expand_aliases
#Directorio de configuración
vconfigdir=./definecontacto
#Alias de dialog para incluir título y renombrar opciones
alias dialog='dialog --stdout --backtitle "Definir contacto de Icinga" --cancel-label 'Cancelar' --exit-label 'Salir' --yes-label 'Si''
#Establezco la variable de separación para  nueva linea
XIFS=$IFS
IFS=$'\n'
#Variables y arrays varios
vcarpeta=$(egrep -v '#'  $vconfigdir/carpeta)
alista=($(egrep -v '#' $vconfigdir/lista  | awk -F "," '{ print $1 "\n" $2 }'))
aperiodos=($(egrep -v '#' $vconfigdir/periodos | awk -F "," '{ print $1 "\n" $2 }'))
#Establezco la variable de separación a sus valores por defecto
IFS=$XIFS
 
 
#Declaro las funciones del script
 
#fcontacto Establece la variable $vcontacto
function fcontacto(){
unset vcontacto
vcontacto=$(dialog --title "Selección de contacto." --menu "Seleccione el contacto:" 20 80 12 "${alista[@]}" );
if [ $? -ne 0 ]
then
  dialog --title 'Advertencia' --msgbox "No se ha seleccionado ningún contacto." 6 80 ;
  fpregunta ;
fi
}
 
#fperiodo Establece la variable $vperiodo
function fperiodo(){
unset vperiodo
vperiodo=$(dialog --title "Selección del periodo." --menu "Seleccione el periodo deseado:" 20 80 12 "${aperiodos[@]}" );
if [ $? -ne 0 ]
then
  dialog --title 'Advertencia' --msgbox "No se ha seleccionado ningún periodo de notificación." 6 80 ;
  fpregunta ;
fi
}
 
#fpregunta Función de pregunta para loop de ejecución
function fpregunta(){
unset vpregunta
vpregunta=$(dialog --timeout 600 --title "¿Que desea hacer?" --menu "Seleccione una opción:" 10 80 2 "1" "Ir al menú principal" "2" "Salir" 2>/dev/null) ;
if [ "$vpregunta" == "1" ]
then
  finicio ;
else
  clear ;
  exit ;
fi
}
 
#fselecciona Muestra una lista de archivos de configuración almacenados en $vcarpeta y guardas las selecciones en $varchivo
function fselecciona(){
unset varchivo
if [ "$(ls -A $vcarpeta)" ]
then
  varchivo=$(dialog --title "Seleccione el archivo de alerta que desea borrar:" --fselect $vcarpeta/ 20 100 ) ;
  if [ $? -ne 0 ]
  then
    dialog --title 'Advertencia' --msgbox "No se ha seleccionado ningún archivo de configuración." 6 80 ;
    fpregunta ;
  fi
else
  dialog --title 'Advertencia' --msgbox "No se han encontrado archivos de configuración." 6 80 ;
  fpregunta ;
fi
}
 
#fborrar Borra los archivos seleccionados y almacenados en la variable $varchivo
function fborrar(){
dialog --title 'Atención' --yesno "¿Desea borrar el archivo de configuración seleccionado? $varchivo" 8 80 ;
if [ $? -eq 0 ]
then
  rm $varchivo
  if [ $? -eq 0 ]
  then
    dialog --title "¡Hecho!" --msgbox "El archivo $varchivo fue borrado, reiniciar Icinga para aplicar los cambios." 8 80 ;
    fpregunta ;
  else
  ferror ;
fi
else
  dialog --title 'Información' --msgbox "No se realizaron cambios." 6 80 ;
  fpregunta ;
fi
}
 
#ferror Funcion de salida para eventos no identificados
function ferror(){
dialog --title "Error" --msgbox "Ha ocurrido un error, vuelva a ejecutar el script y/o verifique la carpeta $vcarpeta." 6 80 ;
clear ;
exit 1;
}
 
#fescribir Escribe la configuración en base a las variables seleccionadas
function fescribir(){
if [ -f $vcarpeta/sms-$vcontacto-$vperiodo.cfg ]
then
  dialog --title 'Advertencia' --msgbox "Ya existe un archivo para el usuario $vcontacto y el período de notificación $vperiodo. No se pueden establecer alertas duplicadas." 6 80 ;
  fpregunta ;
else
  dialog --title 'Atención' --yesno "¿Desea definir una alerta por SMS para el usuario $vcontacto en el período $vperiodo?" 6 80 ;
  if [ $? -eq 0 ]
  then
    echo -e "define contact{\n\t\tcontact_name\t\t\tsms-$vcontacto-$vperiodo\n\t\tuse\t\t\t\t$(cat $vconfigdir/lista | grep $vcontacto | awk -F "," '{ print $4 }')\n\t\talias\t\t\t\t$(echo "SMS $(cat $vconfigdir/lista | grep $vcontacto | awk -F "," '{ print $2 }')")\n\t\thost_notification_period\t$vperiodo\n\t\tservice_notification_period\t$vperiodo\n\t\tpager\t\t\t\t$(cat $vconfigdir/lista | grep $vcontacto | awk -F "," '{ print $3 }')\n\t\t}" > $vcarpeta/sms-$vcontacto-$vperiodo.cfg ;
    if [ $? -eq 0 ]
    then
      dialog --title "¡Hecho!" --msgbox "Archivo de configuración escrito correctamente. Reinicie Icinga para aplicar los cambios." 6 80 ;
      fpregunta ;
    else
      ferror ;
    fi
  else
    dialog --title "Advertencia" --msgbox "No se han efectuado cambios." 6 80 ;
    fpregunta ;
  fi
fi
}
 
#freinicia Función para reiniciar Icinga
function freinicia(){
dialog --title 'Atención' --yesno "¿Desea reiniciar el servicio de Icinga?" 6 80 ;
if [ $? -eq 0 ]
then
  sudo /etc/init.d/icinga restart >/dev/null;
  if [ $? -eq 0 ]
  then
    dialog --title "¡Hecho!" --msgbox "Servicio reiniciado." 6 80 ;
    fpregunta ;
  else
    ferror ;
  fi
else
  dialog --title "Advertencia" --msgbox "No se han efectuado cambios, por lo que cualquier configuración nueva o borrada aún no ha sido procesada por Icinga." 6 80 ;
  fpregunta ;
fi
}
 
#finicio Función principal que llama a las subfunciones  o termina la ejecución en base a la variable $vinicio
function finicio(){
unset vinicio
vinicio=$(dialog --timeout 600 --title "Menú principal" --menu "Seleccione una opción:" 12 80 4 1 "Nueva alerta" 2 "Reiniciar Icinga" 3 "Administrar alertas" 4 "Salir") ;
if [ $vinicio == 1 ]
then
  fcontacto ;
  fperiodo ;
  fescribir ;
elif [ $vinicio == 2 ]
then
  freinicia ;
elif [ $vinicio == 3 ]
then
  fselecciona ;
  fborrar ;
else
  clear ;
  exit ;
fi
}
 
#Finalmente llamo a la función finicio para ejecutar el script
finicio ;
