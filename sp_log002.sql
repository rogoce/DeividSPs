-- Procedimiento que crea el registro de hojas para el archivo de documentos

-- Creado    : 31/08/2011 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_log002;

create procedure sp_log002(
a_no_poliza	char(10),
a_no_endoso	char(5)
) returning integer,
            char(50);

define _no_hoja			char(10);
define _instancia		char(10);
define _origen			smallint;
define _user_added		char(8);
define _imp_num			char(20);

define _cod_sucursal	char(3);
define _nueva_renov		char(1);
define _no_documento	char(20);
define _no_factura		char(10);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc; 
end exception

-- Lectura de la Tabla de Facturas

select user_added,
       no_hoja,
	   no_documento,
	   no_factura
  into _user_added,
       _no_hoja,
	   _no_documento,
	   _no_factura
  from endedmae 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _no_hoja is not null then
	return 0, "Actualizacion Exitosa";
end if

-- Determinar el Origen y el Numero de Instancia

let _instancia = null;
let _origen    = null;

-- Evaluaciones Salud

if _origen is null then

	if a_no_endoso = "00000" then
		
		select no_evaluacion
		  into _instancia
		  from emievalu
		 where no_poliza = a_no_poliza;

		if _instancia is not null then
			let _origen = 4;
		end if

	end if

end if

-- Emisiones Polizas WEB
{
if _origen is null then

	if a_no_endoso = "00000" then
		
		select cod_sucursal,
		       nueva_renov
		  into _cod_sucursal,
		       _nueva_renov
		  from emipomae
		 where no_poliza = a_no_poliza;

		if _cod_sucursal = "009" and
		   _nueva_renov  = "N"   then
			let _origen = 3;
		end if

	end if

end if
}

-- Verificaciones Finales

if _origen is null then

	return 0, "Actualizacion Exitosa";
--	let _origen    = 0;
--	let _instancia = _no_hoja;

end if

-- Generar el Archivo de Hojas para Archivar

let _no_hoja = sp_sis13("001", 'LOG', '02', 'log_no_hoja');

-- Validaciones de Origen

if _origen = 3 then
	let _instancia = _no_hoja;
end if

-- Texto de la Impresion

let _imp_num = sp_log003(_origen, _instancia);

-- Actualizaciones

insert into dighoja(
no_hoja,
origen,
no_instancia,
no_caja,
date_added,
user_added,
archivada,
date_archivada,
user_archivada,
texto_imp,
no_documento,
no_factura
)
values(
_no_hoja,
_origen,
_instancia,
null,
today,
_user_added,
0,
null,
null,
_imp_num,
_no_documento,
_no_factura
);

-- Actualizacion de Endosos

update endedmae
   set no_hoja   = _no_hoja
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

end

return 0, "Actualizacion Exitosa";

end procedure
