-- Polizas para Ducruet

-- Creado    : 17/06/2004 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_pro147;

create procedure "informix".sp_pro147()
returning char(50),
		  char(20),
		  date,
		  date,
		  date,
		  char(100),
		  dec(16,2),
		  dec(16,2),
		  char(20);

define _cod_ramo			char(3);
define _no_documento		char(20);
define _fecha_suscripcion	date;
define _vigencia_inic		date;
define _vigencia_final		date;
define _cod_contratante		char(10);
define _estatus_poliza		smallint;
define _nombre_ramo			char(50);
define _nombre_cliente		char(100);
define _suma_asegurada		dec(16,2);
define _prima_bruta			dec(16,2);
define _estatus_char		char(20);
define _no_poliza			char(10);
define _cantidad			smallint;

foreach
 select no_documento
   into _no_documento
   from emipomae p, emipoagt a
  where p.no_poliza  = a.no_poliza
    and a.cod_agente = "00035"
    and actualizado  = 1
  group by 1
	
	let _no_poliza = sp_sis21(_no_documento);

	select count(*)
	  into _cantidad
	  from emipoagt
	 where no_poliza  = _no_poliza
	   and cod_agente = "00035";

	if _cantidad = 0 then
		continue foreach;
	end if

	select cod_ramo,
	       no_documento,
		   fecha_suscripcion,
		   vigencia_inic,
		   vigencia_final,
		   cod_contratante,
		   estatus_poliza
	  into _cod_ramo,
	       _no_documento,
		   _fecha_suscripcion,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_contratante,
		   _estatus_poliza
      from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza = 1 then
		let _estatus_char = "VIGENTE";
	elif _estatus_poliza = 3 then
		let _estatus_char = "VENCIDA";
	else
		let _estatus_char = "CANCELADA";
	end if

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select sum(suma_asegurada),
	       sum(prima_bruta)
	  into _suma_asegurada,
	       _prima_bruta
	  from endedmae
	 where no_poliza   = _no_poliza
	   and actualizado = 1;

	return _nombre_ramo,
		   _no_documento,
		   _fecha_suscripcion,
		   _vigencia_inic,
		   _vigencia_final,
		   _nombre_cliente,
		   _prima_bruta,
		   _suma_asegurada,
		   _estatus_char
		   with resume;



end foreach

end procedure