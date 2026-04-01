-- Proceso que verifica si una solicitud tiene mas de 15 dias
-- Creado por :     Roman Gordon	09/02/2011
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_verif_susp;
create procedure "informix".sp_verif_susp()
returning char(10)		as Evaluacion,
		  smallint		as Dias_Suspension,
		  varchar(50)	as Ejecutivo,
		  char(30)		as Correo_Ejecutivo;

define _nom_ejec        varchar(50);
define _usuario			varchar(50);
define _e_mail          char(30);
define _no_evaluacion	char(10);
define _cant_dias		smallint;
define _fecha_suspenso	date;
define _fecha_hoy		date;

set isolation to dirty read;

--set debug file to "sp_verif_susp.trc";
--trace on;

let _fecha_hoy = sp_sis40();
let _nom_ejec  = "";

foreach
	select fecha_suspenso,
		   no_evaluacion,
		   nombre_ejecutivo,
		   _fecha_hoy - fecha_suspenso
	  into _fecha_suspenso,
		   _no_evaluacion,
		   _usuario,
		   _cant_dias
	  from emievalu
	 where suspenso = 1
	   and _fecha_hoy - fecha_suspenso in (15,30)

	if _usuario is null then
		let _usuario = '';
		let _nom_ejec = '';
		let _e_mail = '';
	end if

	if _usuario <> '' then
		let _usuario = trim(_usuario);

		select descripcion,
			   e_mail
		  into _nom_ejec,
			   _e_mail
		  from insuser
		 where usuario = _usuario;
	end if
   		
	return _no_evaluacion,
		   _cant_dias,
		   _nom_ejec,
		   _e_mail
		   with resume;
end foreach
end procedure;