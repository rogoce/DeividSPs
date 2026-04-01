-- Procedimiento para arregla las polizas con periodo de pago anual con vencimiento al final de la vigencia
--
-- Creado    : 18/03/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob269;

create procedure "informix".sp_cob269()
returning char(20),
          date,
		  date,
		  date,
		  char(50),
		  char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _vigencia_inic	date;
define _vigencia_final	date;
define _fecha_1_pago	date;

define _cod_formapag	char(3);
define _nombre_forma	char(50);

define _cod_agente		char(5);
define _cod_cobrador	char(3);
define _nombre_cobra	char(50);

set isolation to dirty read;

foreach
 select no_documento,
        vigencia_inic,
		vigencia_final,
		fecha_primer_pago,
		no_poliza,
		cod_formapag
   into	_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_fecha_1_pago,
		_no_poliza,
		_cod_formapag
   from emipomae
  where cod_perpago    = "008"
	and vigencia_final = fecha_primer_pago
	and	estatus_poliza = 1

	select nombre,
	       cod_cobrador
	  into _nombre_forma,
	       _cod_cobrador
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	if _cod_cobrador is null then

		foreach
		 select cod_agente
		   into _cod_agente
		   from emipoagt
		  where no_poliza = _no_poliza
			exit foreach;
		end foreach

		select cod_cobrador
		  into _cod_cobrador
		  from agtagent
		 where cod_agente = _cod_agente;

		select nombre
		  into _nombre_cobra
		  from cobcobra
		 where cod_cobrador = _cod_cobrador;

	else

		let _cod_cobrador =	_cod_formapag;
		let _nombre_cobra = _nombre_forma;
		 
	end if

	{
	update emipomae
	   set fecha_primer_pago = vigencia_inic
	 where no_poliza = _no_poliza;

	update endedmae
	   set fecha_primer_pago = vigencia_inic
	 where no_poliza = _no_poliza
	   and no_endoso = "00000";

	update endedhis
	   set fecha_primer_pago = vigencia_inic
	 where no_poliza = _no_poliza
	   and no_endoso = "00000";
	}

	return _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_1_pago,
		   _nombre_forma,
		   _nombre_cobra
		   with resume;

end foreach


return "",
       null,
	   null,
	   null,
	   "",
	   "";

end procedure

