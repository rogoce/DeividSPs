-- Procedimiento que Modifica la descripcion de las polizas de col de vida grupo sunctracs para su renovacion
-- Creado     : 17/01/2013  -- Autor: Armando Moreno
-- SIS v.2.0 -- DEIVID, S.A.
Drop procedure sp_suntracs;
create procedure "informix".sp_suntracs()
returning smallint,Char(255);
define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _no_poliza		char(10);
define _no_unidad		char(5);
define _no_endoso		char(5);
define _no_factura		char(10);
define _user_added		char(8);
define _estatus_poliza	smallint;
define _fecha_end_canc	date;
define _cancelada		smallint;
define _fecha_canc		date;
define _fecha_perdida	date;
define _fecha_vence 	date;

-- Vigencia Actual
define _no_poliza2		char(10);
define _estatus_poliza2 smallint;
define _desc_estatus	char(10);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(255);

define _descripcion		char(255);
define _cnt		integer;
define _cod_cliente		char(10);
define _saldo_canc		dec(16,2);

--set debug file to "sp_cob252.trc";
--trace on;

set isolation to dirty read;
--return 0,"Realizado Exitosamente. En Base de prueba de Sistema.";
--begin work;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _saldo_canc = 0;
 
foreach	
	select no_poliza
	  into _no_poliza
	  from emirepo
	 where no_documento[1,2] = '16'
	   and user_added = 'AUTOMATI'
	   and estatus = 1
	   and cod_agente = '00180'



	let _cnt = 0;

	select count(*)
	  into _cnt
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = '00001';

	if _cnt = 0 then
		continue foreach;
	end if


	select count(*)
	  into _cnt
	  from emipode2
	 where no_poliza = _no_poliza
	   and no_unidad = '00001';

	if _cnt > 0 then
		continue foreach;
	end if

	if _no_poliza = '604872' then
		continue foreach;
	end if

	INSERT INTO emipode2(
    no_poliza,
    no_unidad,
    descripcion
	)
	SELECT _no_poliza,
		   '00001',
		   descripcion
	  FROM emipode2
     WHERE no_poliza = '604872'
       AND no_unidad = '00001';		

end foreach
return 0,"Realizado Exitosamente.";
end 

end procedure
 
 		