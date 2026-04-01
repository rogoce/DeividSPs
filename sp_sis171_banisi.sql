-- Procedimiento que Determina el Reaseguro para un Cobro para las polizas de Colect. de Vida Degravamen
-- Creado      : 28/02/2023 - Autor: Roman Gordon

drop procedure sp_sis171_banisi;
create procedure sp_sis171_banisi(a_no_poliza char(10), a_no_cambio smallint)
returning integer, char(250);

define _no_poliza			char(10);
define _periodo_emi			char(7);
define _periodo_vig			char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _prima_susc_total	dec(16,2); 
define _prima_contrato		dec(16,2); 
define _porc_partic_prima	dec(9,6); 
define _porc_partic_suma	dec(9,6); 
define _no_cambio			smallint;
define _orden				smallint;
define _cnt					smallint;
define _error				integer;
define _vig_endoso			date;
define _fecha_hoy			date;


set isolation to dirty read;

--set debug file to "sp_sis171_banisi.trc";
--trace on;

begin
	ON EXCEPTION SET _error 
		RETURN _error, 'Error al Actualizar el Endoso ' || a_no_poliza;         
	END EXCEPTION           

drop table if exists tmp_emireaco;
create temp table tmp_emireaco(
		no_poliza    		char(10),
		no_unidad           char(5),
		no_cambio           smallint,
		cod_cober_reas      char(3),
		orden               smallint,
		cod_contrato        char(5),
		porc_partic_suma	dec(9,6), 	
		porc_partic_prima	dec(9,6)
		) with no log;

	let _no_unidad = '00001';
	
	select par_periodo_ant
	  into _periodo_emi
	 from parparam;

	--let _periodo_emi = '2023-12';
	let _vig_endoso = mdy(_periodo_emi[6,7],1,_periodo_emi[1,4]);

	select sum(prima_suscrita)
	  into _prima_susc_total
	  from endedmae
	 where no_poliza = a_no_poliza
	   and periodo = _periodo_emi
	   and vigencia_inic = _vig_endoso
	   and actualizado = 1;
		
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
		   and no_unidad      = _no_unidad
		   and no_cambio      = a_no_cambio

		select sum(rea.prima)
		  into _prima_contrato
		  from endedmae emi
		 inner join emifacon rea on rea.no_poliza = emi.no_poliza and rea.no_endoso = emi.no_endoso
		 where rea.no_poliza = a_no_poliza
		   and emi.periodo = _periodo_emi
		   and emi.vigencia_inic = _vig_endoso
		   and rea.cod_contrato = _cod_contrato
		   and emi.actualizado = 1;

		let _porc_partic_prima = (_prima_contrato/_prima_susc_total) * 100;
		let _porc_partic_suma = _porc_partic_prima;
		
		insert into tmp_emireaco(
			no_poliza,    	
			no_unidad,        
			no_cambio,        
			cod_cober_reas,   
			orden,            
			cod_contrato,     
			porc_partic_suma,
			porc_partic_prima)
			values(
			a_no_poliza, 
			_no_unidad,
			a_no_cambio,
			_cod_cober_reas,
			_orden,
			_cod_contrato,
			_porc_partic_suma,
			_porc_partic_prima
			);
	end foreach

	
	Return 0, "Actualizacion Exitosa ...";
end 
end procedure;