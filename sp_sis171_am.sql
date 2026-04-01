-- Procedimiento que Determina el Reaseguro para un Cobro
-- 
-- Creado      : 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 25/04/2016 -Federico Coronado. 3 en 1 

drop procedure sp_sis171_am;
create procedure sp_sis171_am(a_no_poliza char(10), a_no_unidad char(5), a_no_cambio smallint, a_suma_asegurada dec(16,2))
returning dec(16,2), dec(16,2), dec(16,2);

define _no_poliza			char(10);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6); 
define _porc_partic_suma	dec(9,6);
define _porcentaje          dec(9,6);
define _suma                dec(16,2);
define _porc_proporcion		dec(16,6);
define _no_cambio			smallint;
define _orden				smallint;
define _cnt,_cnt1,_tipo,_valor			smallint;
define _error				integer;
define _mensaje             char(50);
define _suma_retencion,_suma_contrato,_suma_facultativo	dec(16,2);
define _suma_asegurada   dec(16,2);

set isolation to dirty read;

begin
	ON EXCEPTION SET _error 
		RETURN _error, 0, 0;
	END EXCEPTION           


if a_suma_asegurada = 0 then
	return 0,0,0;
end if	

drop table if exists tmp_emireaco;
create temp table tmp_emireaco(
no_poliza    		char(10),
no_unidad           char(5),
no_cambio           smallint,
cod_cober_reas      char(3),
orden               smallint,
cod_contrato        char(5),
porc_partic_suma	dec(9,6), 	
porc_partic_prima	dec(9,6),
suma                dec(16,2)
) with no log;
		
call sp_sis188(a_no_poliza) returning _error,_mensaje;

select count(*)
  into _cnt
  from emireaco
 where no_poliza      = a_no_poliza
   and no_unidad      = a_no_unidad
   and no_cambio      = a_no_cambio;

if _cnt is null then
	let _cnt = 0;
end if

if _cnt = 0 then
	let _no_cambio = null;
	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza      = a_no_poliza
	   and no_unidad      = a_no_unidad;
	   
	if _no_cambio is null then
		let a_no_cambio = 0;
	else
		let a_no_cambio = _no_cambio;
	end if
end if

select count(distinct cod_cober_reas)
  into _cnt1
  from tmp_dist_rea;

select count(distinct cod_cober_reas)
  into _cnt
  from emireaco
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad
   and no_cambio = a_no_cambio;

if _cnt < _cnt1 then
	let _valor = sp_arregla_emireaco_auto_uni(a_no_poliza,a_no_unidad);
	--let _valor = sp_arregla_emireaco_auto(a_no_poliza,1);
	
	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza      = a_no_poliza
	   and no_unidad      = a_no_unidad;
	   
	let a_no_cambio = _no_cambio;
end if   

select sum(porc_cober_reas)
  into _porc_proporcion
 from tmp_dist_rea;
 
 if _porc_proporcion > 100 then
	delete from tmp_dist_rea
	 where cod_cober_reas not in ('031','034');
	 
	update tmp_dist_rea
	   set porc_cober_reas = 100
	 where cod_cober_reas in ('031','034');
 end if

foreach
		select cod_contrato,
			   porc_partic_prima,
			   orden,
			   porc_partic_suma,
			   cod_cober_reas
		  into _cod_contrato,
			   _porc_partic_prima,
			   _orden,
			   _porc_partic_suma,
			   _cod_cober_reas
		  from emireaco
		 where no_poliza      = a_no_poliza
		   and no_unidad      = a_no_unidad
		   and no_cambio      = a_no_cambio
		   
		select porc_cober_reas
		  into _porc_proporcion
		  from tmp_dist_rea
		 where cod_cober_reas = _cod_cober_reas;

     	if _porc_proporcion is null then
			continue foreach;
		end if
		
		let _suma = 0.00;
		let _suma = (a_suma_asegurada * _porc_partic_suma /100) * _porc_proporcion /100;
		   
		insert into tmp_emireaco(
			no_poliza,    	
			no_unidad,        
			no_cambio,        
			cod_cober_reas,   
			orden,            
			cod_contrato,     
			porc_partic_suma,
			porc_partic_prima,
			suma)
			values(
			a_no_poliza, 
			a_no_unidad,
			a_no_cambio,
			_cod_cober_reas,
			_orden,
			_cod_contrato,
			_porc_partic_suma,
			_porc_partic_prima,
			_suma);	      
end foreach
	
let _suma_retencion   = 0;
let _suma_contrato    = 0;
let _suma_facultativo = 0;

drop table tmp_dist_rea;

foreach
	select cod_contrato,
		   suma
	  into _cod_contrato,
		   _suma_asegurada
	  from tmp_emireaco	   
		   
	select tipo_contrato
	  into _tipo
	  from reacomae
	 where cod_contrato = _cod_contrato;
	
	if _tipo = 1 then	--Retencion
		let _suma_retencion = _suma_retencion + _suma_asegurada;
	elif _tipo = 3 then --facultativo
		let _suma_facultativo = _suma_facultativo + _suma_asegurada;
	else
		let _suma_contrato = _suma_contrato + _suma_asegurada;
	end if
end foreach
	
Return _suma_retencion,_suma_contrato,_suma_facultativo;
end 
end procedure;