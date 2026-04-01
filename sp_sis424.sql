-- Procedimeinto para actualizar el monto de la visa o ach en mantenimiento de visa/ach cuando la vigencia entre en vigor.
-- Creado    : 02/05/2013 - Autor: Armando Moreno M.
-- Modificado: 02/05/2013 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis424;
create procedure "informix".sp_sis424(a_no_documento char(20), a_fecha date, a_fecha2 date)
returning dec(16,2);

define v_prima_cobrada		dec(16,2);
define _porcentaje			dec(7,4);
define v_prima_retencion	dec(16,2);
define v_prima_excedente	dec(16,2);
define v_prima_facultativo	dec(16,2);
define _no_remesa           char(10);
define _renglon           	integer;
define v_tipo_contrato      smallint;
define v_cod_contrato       CHAR(5);
define _porc_partic_prima	dec(9,6);
define _porc_proporcion     dec(5,2);
define v_cobertura          CHAR(3);
define _es_terremoto        smallint;  
define _no_poliza           char(10);     


--drop table temp_prima_cob;
create temp table temp_prima_cob(
no_documento		char(20),
retencion			dec(16,2),
excedente	        dec(16,2),
facultativo			dec(16,2),
primary key (no_documento)) with no log;

-- Prima cobrada para terremoto

let v_prima_cobrada = 0;
let v_prima_retencion = 0;
let v_prima_facultativo = 0;
let v_prima_excedente = 0;

FOREACH
	SELECT d.no_remesa,
	       d.renglon,
	       d.prima_neta, -- d.monto,  Solicito:RGORDON 28/08/2017
		   d.no_poliza
	 INTO _no_remesa,
	      _renglon,
	      v_prima_cobrada,
		  _no_poliza
	 FROM cobredet d, cobremae m
	WHERE d.cod_compania = '001'
	  AND d.actualizado  = 1
	  AND d.fecha        >= a_fecha
	  AND d.fecha        <= a_fecha2
	  AND d.tipo_mov     IN ('P','N')
	  AND d.doc_remesa   = a_no_documento
	  AND d.no_remesa    = m.no_remesa
	  AND m.tipo_remesa  IN ('A', 'M', 'C','B')

	SELECT porc_partic_coas
	  INTO _porcentaje
	  FROM emicoama
	 WHERE no_poliza    = _no_poliza
	   AND cod_coasegur = "036";
	   
	IF _porcentaje IS NULL THEN
		LET _porcentaje = 100;
	END IF	    

	LET v_prima_cobrada = v_prima_cobrada / 100 * _porcentaje;
	
	FOREACH
		select cod_contrato,
			   porc_partic_prima,
			   porc_proporcion,
			   cod_cober_reas
		  into v_cod_contrato,
			   _porc_partic_prima,
			   _porc_proporcion,
			   v_cobertura
		  from cobreaco
		 where no_remesa = _no_remesa
		   and renglon   = _renglon
		   
		   select es_terremoto
		     into _es_terremoto
			 from reacobre
			where cod_cober_reas = v_cobertura;
			
			if _es_terremoto = 0 then
				continue foreach;
			end if

			Select tipo_contrato
			  Into v_tipo_contrato
			  From reacomae
			 Where cod_contrato = v_cod_contrato;
			
			let v_prima_retencion = 0;
			let v_prima_facultativo = 0;
			let v_prima_excedente = 0;
			
			if v_tipo_contrato = 3 THEN --Facultativo

			   let v_prima_facultativo = v_prima_cobrada * (_porc_partic_prima / 100) * (_porc_proporcion / 100);

			elif v_tipo_contrato = 1 then --Retencion

			   let v_prima_retencion = v_prima_cobrada * (_porc_partic_prima / 100) * (_porc_proporcion / 100);
			   
			else
			
			   let v_prima_excedente = v_prima_cobrada * (_porc_partic_prima / 100) * (_porc_proporcion / 100);
			   
			end if
			
				begin
					on exception in(-239)
						update temp_prima_cob			   
						   set retencion   		= retencion + v_prima_retencion,
							   excedente        = excedente + v_prima_excedente,
							   facultativo      = facultativo + v_prima_facultativo
					     where no_documento = a_no_documento;
					end exception

					insert into temp_prima_cob
					   values(a_no_documento,
							  v_prima_retencion,
							  v_prima_excedente,
							  v_prima_facultativo);
				end

	END FOREACH
END FOREACH

 select sum(retencion),
        sum(excedente),
		sum(facultativo)
   into v_prima_retencion,
        v_prima_excedente,
		v_prima_facultativo
   from temp_prima_cob;
   
 if v_prima_retencion is null then
	let v_prima_retencion = 0;
 end if
  if v_prima_excedente is null then
	let v_prima_excedente = 0;
  end if
 if v_prima_facultativo is null then
	let v_prima_facultativo = 0;
 end if

 let v_prima_cobrada = v_prima_retencion + v_prima_excedente + v_prima_facultativo;   

 drop table temp_prima_cob;
 
 return v_prima_cobrada;


end procedure;