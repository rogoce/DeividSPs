drop procedure ap_corrige_reaseguro;
create procedure "informix".ap_corrige_reaseguro()
returning integer, varchar(50);

define _cod_ramo		char(3);
define _cod_rammo   	char(3);
define _valor       	integer;
define _mensaje     	char(50);
define _vig_ini     	date;
define _vigencia_final 	date;
define _cnt             integer;
define _cod_ruta        char(5);
define _serie           integer;
define _no_cambio       smallint;
define _no_unidad       char(5);
define _suma_asegurada  dec(16,2);
define _cod_cober_reas  char(3);
define _orden           smallint;
define _cod_contrato    char(5);
define _porc_prima      dec(9,6);
define _porc_suma       dec(9,6);
define _tipo_contrato   smallint;
define _fronting        smallint;
define _cant            smallint;
define _error           integer;

let _valor = 0;
let _mensaje = "";


--SET DEBUG FILE TO "ap_corrige_reaseguro.trc";
--TRACE ON;

set isolation to dirty read;

begin work;

begin

on exception set _error 
	rollback work;
 	return _error, "Error";         
end exception           


 --buscar ruta
select cod_ramo,vigencia_inic, vigencia_final
  into _cod_ramo,_vig_ini,_vigencia_final
  from emipomae
 where no_poliza = '842034';
  
 let _cod_rammo = _cod_ramo;

select count(*)
  into _cnt
  from rearumae
 where cod_ramo = _cod_ramo
   and activo   = 1
   and _vig_ini between vig_inic and vig_final;

if _cnt = 0 then
	return 2, 'No Existe Ruta de Reaseguro para esta Vigencia';  --_mensaje;
end if

foreach
	select cod_ruta,serie
	  into _cod_ruta,_serie
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and activo   = 1
 	   and _vig_ini between vig_inic and vig_final
	exit foreach;
end foreach

select max(no_cambio)
  into _no_cambio
  from emireama
 where no_poliza = '749923';
	
foreach
    select no_unidad, suma_asegurada
      into _no_unidad, _suma_asegurada
      from endeduni  
     where no_poliza = '842034'
       and no_endoso = '00000'
	   and no_unidad not in ('00001','00017','00030')
	   	   
	foreach
		select no_unidad,
			   cod_cober_reas,
			   orden,
			   cod_contrato,
			   porc_partic_suma,
			   porc_partic_prima
		  into _no_unidad,
			   _cod_cober_reas,
			   _orden,
			   _cod_contrato,
			   _porc_suma,
			   _porc_prima
		   from emireaco
		  where no_poliza = '749923'
		    and no_cambio = _no_cambio
			and no_unidad = _no_unidad

			let _fronting  = 0;

		select tipo_contrato,
			   fronting
		  into _tipo_contrato,
			   _fronting
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _cod_rammo in ('002','023') then
			foreach
			    select cod_cober_reas,
				       orden,
					   cod_contrato,
					   porc_partic_suma,
					   porc_partic_prima
				  into _cod_cober_reas,
				       _orden,
					   _cod_contrato,
					   _porc_suma,
					   _porc_prima
				  from rearucon r, rearumae e
				 where r.cod_ruta     = e.cod_ruta
				   and e.cod_ramo     = _cod_rammo
				   and e.activo       = 1
				   and e.cod_ruta     = _cod_ruta

				select count(*)
				  into _cant
				  from emifacon		  
				 where no_poliza	  = '842034'
				   and no_endoso	  = '00000'
				   and no_unidad	  = _no_unidad
				   and cod_cober_reas = _cod_cober_reas
				   and orden		  = _orden;

				if _cant = 0 then
					insert into emifacon(
							no_poliza,
							no_endoso,
							no_unidad,
							cod_cober_reas,
							orden,
							cod_contrato,
							cod_ruta,
							porc_partic_prima,
							porc_partic_suma,
							suma_asegurada,
							prima)
					values(	'842034',
							"00000",
							_no_unidad,
							_cod_cober_reas,
							_orden,
							_cod_contrato,
							_cod_ruta,
							_porc_prima,
							_porc_suma,
							0.00,
							0.00);
				end if
			end foreach
		else
			foreach
				select cod_contrato
				  into _cod_contrato
				  from reacomae
				 where tipo_contrato = _tipo_contrato
				   and serie = _serie
				   and fronting      = _fronting

				select count(*)
				  into _cnt
				  from rearucon r, rearumae e
				 where r.cod_ruta     = e.cod_ruta
				   and r.cod_contrato = _cod_contrato
				   and e.cod_ramo     = _cod_rammo
				   and e.activo       = 1
				   and e.serie        = _serie;

				if _cnt = 0 then
				else
				  exit foreach;
				end if
			end foreach
			
			select count(*)
			  into _cant
			  from emifacon		  
			 where no_poliza	  = '842034'
			   and no_endoso	  = '00000'
			   and no_unidad	  = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and orden		  = _orden;

			if _cant = 0 then
				insert into emifacon(
						no_poliza,
						no_endoso,
						no_unidad,
						cod_cober_reas,
						orden,
						cod_contrato,
						cod_ruta,
						porc_partic_prima,
						porc_partic_suma,
						suma_asegurada,
						prima)
				values(	'842034',
						"00000",
						_no_unidad,
						_cod_cober_reas,
						_orden,
						_cod_contrato,
						_cod_ruta,
						_porc_prima,
						_porc_suma,
						0.00,
						0.00);
			end if

		end if
	end foreach
	
	call sp_pro323('842034',_no_unidad,_suma_asegurada,'001') returning _valor;
	
	if _valor <> 0 then
	    rollback work;
		let _mensaje = "Error";
		exit foreach;
	end if
	
	FOREACH
	 SELECT	cod_cober_reas
	   INTO	_cod_cober_reas
	   FROM	emifacon
	  WHERE	no_poliza = '842034'
		AND no_endoso = '00000'
		and no_unidad = _no_unidad
	  GROUP BY no_unidad, cod_cober_reas

		INSERT INTO emireama(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		vigencia_inic,
		vigencia_final
		)
		VALUES(
		'842034', 
		_no_unidad,
		_no_cambio,
		_cod_cober_reas,
		_vig_ini,
		_vigencia_final
		);

	END FOREACH

	INSERT INTO emireaco(
	no_poliza,
	no_unidad,
	no_cambio,
	cod_cober_reas,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima
	)
	SELECT 
	'842034', 
	no_unidad,
	_no_cambio,
	cod_cober_reas,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima
	FROM emifacon
	  WHERE	no_poliza = '842034'
		AND no_endoso = '00000'
		AND no_unidad = _no_unidad;

	INSERT INTO emireafa(
	no_poliza,
	no_unidad,
	no_cambio,
	cod_cober_reas,
	orden,
	cod_contrato,
	cod_coasegur,
	porc_partic_reas,
	porc_comis_fac,
	porc_impuesto
	)
	SELECT 
	'842034', 
	no_unidad,
	_no_cambio,
	cod_cober_reas,
	orden,
	cod_contrato,
	cod_coasegur,
	porc_partic_reas,
	porc_comis_fac,
	porc_impuesto
	FROM emifafac
	  WHERE	no_poliza = '842034'
		AND no_endoso = '00000'
		AND no_unidad = _no_unidad;

end foreach
commit work;
end
   
   return _valor, _mensaje;
	
end procedure
