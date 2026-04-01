-- Consulta de Requisiciones para un bloque
-- 
-- Creado    : 19/01/2007 - Autor: Demetrio Hurtado Almanza

DROP PROCEDURE sp_atc003;

CREATE PROCEDURE "informix".sp_atc003(a_cod_entrada char(10))
returning char(10),
          integer,
		  char(50),
		  date,
		  date,
		  char(8),
		  date,
		  char(8),
		  date,
		  date,
		  date,
		  char(8),
		  date,
		  char(8),
		  char(50),
		  char(50),
		  date,
		  char(50),
		  dec(16,2),
		  char(1),
		  char(8),
		  date,
		  varchar(30);

define _no_requis		char(10);
define _no_cheque		integer;
define _a_nombre_de		char(50);
define _fecha_captura	date;
define _fecha_firma_0	date;
define _user_firma_1	char(8);
define _fecha_firma_1	date;
define _user_firma_2	char(8);
define _fecha_firma_2	date;
define _fecha_impresion	date;
define _fecha_anulado	date;
define _user_anulo		char(8);
define _fecha_entrega	date;
define _user_entrego	char(8);
define _persona_retiro	char(50);
define _persona_cedula	char(50);
define _fecha_cobrado	date;
define _cod_ruta		char(2);
define _nombre_ruta		char(50);
define _impreso			smallint;
define _monto			dec(16,2);
define _tipo_requis     char(1);
define _user_pre_aut    char(8);
define _date_pre_aut    date;
define _en_firma   	    smallint;
 

set isolation to dirty read;

foreach
	select c.no_requis
	  into _no_requis
	  from atcdocde d, rectrmae t, chqchmae c
	 where d.cod_asignacion = t.cod_asignacion
	   and t.no_requis      = c.no_requis
	   and d.cod_entrada    = a_cod_entrada
	 group by 1
	 order by 1

	select no_cheque,
	       a_nombre_de,
	       fecha_captura,
		   fecha_paso_firma,
		   firma1,
		   fecha_firma1,
		   firma2,
		   fecha_firma2,
		   fecha_impresion,
		   fecha_anulado,
		   anulado_por,
	  	   wf_fecha,
		   user_entrego,
		   wf_nombre,
		   wf_cedula,
		   fecha_cobrado,
		   cod_ruta,
		   pagado,
		   monto,
		   tipo_requis,
		   user_pre_aut,
		   date_pre_aut,
		   en_firma
	  into _no_cheque,
	       _a_nombre_de,
	       _fecha_captura,
		   _fecha_firma_0,
		   _user_firma_1,
		   _fecha_firma_1,
		   _user_firma_2,
		   _fecha_firma_2,
		   _fecha_impresion,
		   _fecha_anulado,
		   _user_anulo,
		   _fecha_entrega,
		   _user_entrego,
		   _persona_retiro,
		   _persona_cedula,
		   _fecha_cobrado,
		   _cod_ruta,
		   _impreso,
		   _monto,
		   _tipo_requis,
		   _user_pre_aut,
		   _date_pre_aut,
		   _en_firma
	  from chqchmae
	 where no_requis = _no_requis;

	select nombre
	  into _nombre_ruta
	  from chqruta
	 where cod_ruta = _cod_ruta;

	if _impreso = 0 then
		let _fecha_impresion = null;
	end if

	return _no_requis,
		   _no_cheque,
	       _a_nombre_de,
	       _fecha_captura,
		   _fecha_firma_0,
		   _user_firma_1,
		   _fecha_firma_1,
		   _user_firma_2,
		   _fecha_firma_2,
		   _fecha_impresion,
		   _fecha_anulado,
		   _user_anulo,
		   _fecha_entrega,
		   _user_entrego,
		   _persona_retiro,
		   _persona_cedula,
		   _fecha_cobrado,
		   _nombre_ruta,
		   _monto,
		   _tipo_requis,
		   _user_pre_aut,
		   _date_pre_aut,
		   trim((case when _en_firma in(0,4) then "" else (case when _en_firma = 1 then "EN FIRMA" else (case when _en_firma = 2 then "FIRMADO" else (case when _en_firma = 5 then "RECHAZADO" else "" end)end)end)end))
		   with resume;

end foreach
end procedure