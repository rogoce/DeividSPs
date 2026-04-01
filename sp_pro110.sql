-- Procedimiento que trae los Endosos que necesitan autorizacion para emitirse

-- Creado    : 28/02/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 28/02/2003 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro110;

create procedure sp_pro110(a_compania CHAR(3))
returning char(8),
       	  char(20),
	      char(50),
	      char(50),
	      date,
	      char(7),
	      smallint,
	      char(10),
	      char(5),
	      char(3),
	      date,
	      date;

define _user_added		char(8);
define _no_documento	char(20);
define _cod_endomov		char(3);
define _fecha_emision	date;
define _date_added      date;
define _date_autori		date;
define _periodo			char(7);
define _desc_endomov	char(50);
define _cod_cliente		char(10);
define _desc_cliente	char(50);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_autori		char(10);
define _procesar		smallint;

set isolation to dirty read;
--set debug file to "sp_pro110.trc";
--trace on;

foreach
 select	e.user_added,
        e.no_documento,
		e.cod_endomov,
		e.fecha_emision,
		e.periodo,
		e.no_poliza,
		e.no_endoso,
		e.date_added
   into	_user_added,
        _no_documento,
		_cod_endomov,
		_fecha_emision,
		_periodo,
		_no_poliza,
		_no_endoso,
		_date_added
   from	endedmae e, endtimov t
  where	e.cod_endomov    = t.cod_endomov
    and e.cod_compania   = a_compania
	and e.actualizado    = 0
    and t.tiene_password = 1
	and (e.wf_aprob = 0 or e.wf_aprob is null) -- SD # 7564 Amado Pérez M - 21-08-2023
  order by 4 desc

	LET _no_autori = NULL;
	LET _procesar  = 0;

	select no_autori,
		   date_autori	
	  into _no_autori,
		   _date_autori
	  from endbiaut
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	IF _date_autori IS NULL THEN
		LET _date_autori = '';
	ELSE
		LET _procesar = 1;
	END IF

	select nombre
	  into _desc_endomov
	  from endtimov
	 where cod_endomov = _cod_endomov;

	select cod_contratante
	  into _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _desc_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	return _user_added,
	       _no_documento,
		   _desc_cliente,
		   _desc_endomov,
		   _fecha_emision,
		   _periodo,
		   _procesar,
		   _no_poliza,
		   _no_endoso,
		   _cod_endomov,
		   _date_autori,
		   _date_added
		   with resume;
end foreach
end procedure
