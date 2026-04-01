-- Procedimiento que Cambia el Reaseguro para un Cobro en cobreaco a partir de las polizas que fueron cambiadas
-- en cambio de reaseguro masivo que se hizo a las polizas de automovil con vig ini >= 01/07/2013 y que se almacenaron en la tabla
-- camrea
-- 
-- Creado    : 01/10/2013 - Autor: Armando Moreno M.
-- Modificado: 01/10/2013 - Autor: Armando Moreno M.


drop procedure sp_sis171coo;
create procedure 'informix'.sp_sis171coo()
returning integer, varchar(250);

define _mensaje		varchar(250);
define _no_poliza	char(10);
define _no_remesa	char(10);
define _periodo2	char(7);
define _periodo		char(7);
define _cod_ramo	char(5);
define _no_unidad	char(5);
define _error_isam	integer;
define _cantidad	integer;
define _error		integer;
define _cnt			integer;
define _renglon		smallint;

set isolation to dirty read;

--set debug file to 'sp_sis171coo.trc';
--trace on;

let _periodo = '2017-07';
let _cantidad = 0;

begin

on exception set _error,_error_isam,_mensaje
	let _mensaje = trim(_mensaje) || 'Verificar la Remesa: ' || trim(_no_remesa) || ' en el Renglon: ' || trim(cast(_renglon as char(3)));
	rollback work;
 	return _error,_mensaje;
end exception

foreach with hold
	select distinct no_poliza
	  into _no_poliza
	  from	camrea
	 where periodo >= _periodo
	 order by no_poliza

	begin work;

	let _no_remesa = null;

	foreach
		select no_remesa,
			   renglon,
			   periodo
		  into _no_remesa,
			   _renglon,
			   _periodo2
		  from cobredet
		 where periodo = '2017-06'
		   and no_poliza = _no_poliza
		   and tipo_mov in ('P', 'N')
		   and actualizado = 1

		if _no_remesa is null then
			continue foreach;
		end if
	   
		insert into camcobreaco(no_poliza,no_remesa,renglon) 
		values(_no_poliza,_no_remesa,_renglon);

		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		update cobreaco
		   set cod_contrato = '00671'
		 where no_remesa = _no_remesa
		   and renglon = _renglon
          and cod_contrato = '00664';

		if _cod_ramo in ('006','008') then
			update cobreaco
			   set cod_contrato = '00672'
			 where no_remesa    = _no_remesa
			   and renglon      = _renglon
			   and cod_contrato = '00665';
		end if

		if _periodo2 >= '2017-07' then
		    update cobredet
			   set sac_asientos = 0
			 where no_remesa = _no_remesa;

			update sac999:reacomp
			   set sac_asientos = 0
			 where no_remesa = _no_remesa
			   and renglon   = _renglon
			   and tipo_registro = 2;
		end if
	end foreach

	let _cantidad = _cantidad + 1;

	commit work;
end foreach

let _mensaje = 'Actualizacion Exitosa, Registros ' || _cantidad;
return 0, _mensaje;
end
end procedure;