-- Procedimeinto para actualizar el monto de la visa o ach en mantenimiento de visa/ach cuando la vigencia entre en vigor.
-- Creado    : 02/05/2013 - Autor: Armando Moreno M.
-- Modificado: 02/05/2013 - Autor: Armando Moreno M.
-- Modificado: 10/05/2017 - Autor: Henry Giron copia del sp_sis424 se modifica q incluye terremoto e incendio
-- SIS v.2.0 - DEIVID, S.A.  execute procedure sp_rea11('0114-00742-01','01/07/2016','30/06/2017')

drop procedure sp_rea11;
create procedure "informix".sp_rea11(a_no_documento char(20), a_fecha date, a_fecha2 date)
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
define _cod_ramo            CHAR(3);
define _serie				smallint;

 Drop table if exists tmp_prima_cobrada;
 
create temp table tmp_prima_cobrada(
no_documento		char(20),
no_poliza           char(10),
serie               smallint,
cod_cober_reas      char(3),
retencion			dec(16,2),
excedente	        dec(16,2),
facultativo			dec(16,2),
es_terremoto        smallint,
prima_neta          dec(16,2),
porc_partic_coas    dec(7,4),   
porc_partic_prima	dec(9,6),
porc_proporcion     dec(5,2),
primary key (no_documento,no_poliza,serie,cod_cober_reas,es_terremoto )) with no log;

-- Prima cobrada para terremoto
--set debug file to "sp_rea10_1.trc";
--trace on;

let v_prima_cobrada = 0;
let v_prima_retencion = 0;
let v_prima_facultativo = 0;
let v_prima_excedente = 0;
let _serie = 0;

FOREACH
	SELECT d.no_remesa,
	       d.renglon,
	       d.prima_neta,
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
	  AND m.tipo_remesa  IN ('A', 'M', 'C')
	  
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza =	_no_poliza;  

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
			
			if _cod_ramo in ('001','003') then			
				if _es_terremoto = 1 then
					continue foreach;
				end if 
			end if

			Select tipo_contrato,serie
			  Into v_tipo_contrato,_serie
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
						update tmp_prima_cobrada			   
						   set retencion   		= retencion + v_prima_retencion,
							   excedente        = excedente + v_prima_excedente,
							   facultativo      = facultativo + v_prima_facultativo
					     where no_documento = a_no_documento
						   and no_poliza = _no_poliza
						   and serie = _serie 
						   and cod_cober_reas = v_cobertura
						   and es_terremoto = _es_terremoto;
					end exception

					insert into tmp_prima_cobrada
					   values(a_no_documento,
					          _no_poliza,
					          _serie,
							  v_cobertura,
							  v_prima_retencion,
							  v_prima_excedente,
							  v_prima_facultativo,
							  _es_terremoto,
							  v_prima_cobrada,
							  _porcentaje,   
							  _porc_partic_prima,
							  _porc_proporcion							  
							  );
				end

	END FOREACH
END FOREACH
--trace off;
 select sum(retencion),
        sum(excedente),
		sum(facultativo)
   into v_prima_retencion,
        v_prima_excedente,
		v_prima_facultativo
   from tmp_prima_cobrada;
   
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

 --drop table tmp_prima_cobrada;
 
 return v_prima_cobrada;


end procedure;