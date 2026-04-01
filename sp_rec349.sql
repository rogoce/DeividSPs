-- buscar ajustador

-- Creado: 11/03/2024 - Autor: Amado Perez Mendoza

drop procedure sp_rec349;

create procedure sp_rec349(a_no_reclamo CHAR(10), a_factura DATE)
returning  SMALLINT,
		   varchar(70);	

define _no_poliza		char(10);
define _no_unidad		char(5);
define _cod_reclamante	char(10);
define _cnt				smallint;
define _cnt_dep         smallint;
define _fecha_efectiva  date;
define _tipo            varchar(11);
define _error           integer;

let _error = 0;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rwf103.trc"; 
--trace on;

begin

ON EXCEPTION SET _error 
	RETURN _error, 'Error BD'; 
END EXCEPTION         

	select no_poliza,
	       no_unidad,
		   cod_reclamante
	  into _no_poliza,
	       _no_unidad,
		   _cod_reclamante
	  from recrcmae
	 where no_reclamo = a_no_reclamo;
	 
	let _cnt = 0; 
	let _cnt_dep = 0; 
	 
	select count(*) 
	   into _cnt
	   from emipouni 
	  where no_poliza = _no_poliza
	    and no_unidad = _no_unidad
	    and cod_asegurado = _cod_reclamante;
	
	if _cnt is null then
		let _cnt = 0; 
	end if

	if _cnt > 0 then
		select vigencia_inic
		  into _fecha_efectiva
		  from emipouni 
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_asegurado = _cod_reclamante;	
	else
		SELECT count(*) 
	      INTO _cnt
	      FROM endedmae x, endeduni y
	     WHERE y.no_poliza = x.no_poliza
		   AND y.no_endoso = x.no_endoso
		   AND y.no_poliza = _no_poliza
		   AND y.no_unidad = _no_unidad
		   AND y.cod_cliente = _cod_reclamante
	       AND (x.cod_endomov = '011' or x.cod_endomov = '004');

		if _cnt is null then
			let _cnt = 0; 
		end if
		
		if _cnt > 0 then
			FOREACH
				SELECT y.vigencia_inic 
				  INTO _fecha_efectiva
				  FROM endedmae x, endeduni y
				 WHERE y.no_poliza = x.no_poliza
				   AND y.no_endoso = x.no_endoso
				   AND y.no_poliza = _no_poliza
				   AND y.no_unidad = _no_unidad
				   AND y.cod_cliente = _cod_reclamante
				   AND (x.cod_endomov = '011' or x.cod_endomov = '004')
                ORDER BY x.no_endoso desc
                EXIT FOREACH;
            END FOREACH				
		else
			select count(*) 
			   into _cnt_dep
			   from emidepen 
			  where no_poliza = _no_poliza
				and no_unidad = _no_unidad
				and cod_cliente = _cod_reclamante;

			if _cnt_dep is null then
				let _cnt_dep = 0; 
			end if
				
			if _cnt_dep > 0 then
				select fecha_efectiva 
				   into _fecha_efectiva
				   from emidepen 
				  where no_poliza = _no_poliza
					and no_unidad = _no_unidad
					and cod_cliente = _cod_reclamante;
			end if
		end if	
	end if
				 
	if _cnt > 0	then
		let _tipo = 'asegurado';
	end if

	if _cnt_dep > 0	then
		let _tipo = 'dependiente';
	end if
	
	if  a_factura < _fecha_efectiva then
		return 1, 'Fecha de la factura es menor que la fecha efectiva del ' || trim(_tipo);
	else
		return 0, 'Exito';
	end if
end
end procedure