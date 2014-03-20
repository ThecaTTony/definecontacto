definecontacto
==============

Script para definir contactos temporales de Icinga o Nagios

El mismo se pensó para definir contactos de Icinga que necesitan recibir notificaciones por medio de SMS.
La configuración para enviar SMS se puede ver en detalle en el siguiente enlace:

http://www.chriscowley.me.uk/blog/2010/05/04/sms-from-icinga-or-nagios/

**Requerimientos:**

* dialog
* sudo (para reiniciar el servicio de Icinga como usuario regular)

**Archvios y otros:**

* En todos los casos se permiten comentarios en los archivos mientras la línea empiece con el carácter numeral #.
* Se deben poseer permisos de escritura en la carpeta donde se escribirán los archivos de contacto.
Dicha ruta se define en el archivo [./definecontacto/carpeta](definecontacto/carpeta)
* El archivo [./definecontacto/periodos](definecontacto/periodos) debe contener los periodos utilizados por Icinga.
No se utilizan directamente los mismos por dos razones: Los mismos se pueden declarar en varios archivos, la configuración de Icinga es particular a cada caso, y por medio del archivo se pueden dejar solo los periodos a utilizar.
* El script está ideado para trabajar en CentOS, quizás se necesite adaptar el comando que reinicia el servicio de Icinga en otras distribuciones.

**Configurar usuario regular para utilizar sudo sin contraseña:**

Editar el archivo /etc/sudoers y agregar lo siguiente:

```
Cmnd_Alias ICINGA = /etc/init.d/icinga
User_Alias ICINGAUSERS = usuario
ICINGAUSERS ALL = NOPASSWD : ICINGA
```
Una vez hecho el cambio "**usuario**" podrá reiniciar el servicio de Icinga sin necesidad de ingresar contraseña. Si el script corre bajo root, dichos ajustes no son necesarios.
