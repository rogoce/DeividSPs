-- Procedure que Genera el Reporte de Cumulos de Fianzas para la Superintendencia de Seguros
-- Creado    : 10/06/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro397;

create procedure "informix".sp_pro397(a_compania char(3),a_periodo_desde char(7), a_periodo_hasta char(7))
returning	char(21),		--_no_documento,
			char(50),		--_nom_subramo,
			char(50),		--_nom_cliente,
			char(1),--REFERENCES text,--char(200),		descripcion,
			dec(16,2),		--_valor_contrato,
			dec(16,2),		--_suma_asegurada,
			dec(9,6),		--_porc_retencion,
			dec(9,6),		--_porc_cesion,
			date,			--_fecha_emision,
			date,			--_vigencia_inic,
			date,			--_vigencia_final
			char(50),
			char(15);

define _proy				varchar(255);			
define _desc_error			char(100);
define _compania_nombre		char(50);
define _nom_subramo			char(50);
define _nom_cliente			char(50);
define _no_documento		char(21);
define _cod_cliente			char(15);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _unidad				char(5);
define _cod_subramo			char(3);
define _porc_partic_suma	dec(9,6);
define _porc_retencion		dec(9,6);
define _porc_cesion			dec(9,6);
define _valor_contrato		dec(16,2);
define _suma_asegurada		dec(16,2);
define _tipo_contrato		smallint;
define _no_cambio			smallint;
define _anio				smallint;
define _mes					smallint;
define _dia					smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_emision		date;
define _fecha_desde			date;
define _fecha_hasta			date;
define _tipo                char(15);
define _fecha_cancelacion   date;
define _fecha_emision_end   date;

--define _proyecto			REFERENCES text;


--set debug file to "sp_pro397.trc";
--trace on;

set isolation to dirty read;

begin
{on exception set _error,_error_isam,_desc_error
	--return _error,_error_isam,_desc_error;
	drop table tmp_cufian;
end exception}

{create temp table tmp_cufian
   (no_documento		char(21),
	cod_subramo			char(3),
	cod_cliente			char(10),
	proyecto			byte,
	valor_contrato		dec(16,2),
	monto_afianzado		dec(16,2),
	contrato_retencion	dec(16,2),
	contrato_cesion		dec(16,2),
	fecha_emision		date,
	vigencia_inic		date,
	vigencia_final		date)
--primary key(no_aviso,no_poliza,no_documento)) 
with no log;}

delete from tmp_cufian;

let _compania_nombre = sp_sis01(a_compania);
let _dia	= 1;
let _mes	= a_periodo_desde[6,7];
let _anio	= a_periodo_desde[1,4];

let _fecha_desde = mdy(_mes,_dia,_anio);
let _fecha_hasta = sp_sis36(a_periodo_hasta);

foreach
{	select no_poliza,
		   no_documento,
		   vigencia_inic,
		   vigencia_final,
		   cod_subramo,
		   fecha_suscripcion,
		   cod_contratante,
		   fecha_cancelacion
	  into _no_poliza,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_subramo,
		   _fecha_emision,
		   _cod_cliente,
		   _fecha_cancelacion
	  from emipomae
	 where cod_ramo = '008'
       and (vigencia_final   >= _fecha_hasta
		or vigencia_final    IS NULL)
       and fecha_suscripcion <= _fecha_hasta
       and vigencia_inic     <= _fecha_hasta
	   and actualizado = 1
	   
	   LET _fecha_emision_end = null;

	  IF _fecha_cancelacion <= _fecha_hasta THEN
		 FOREACH
			SELECT fecha_emision
			  INTO _fecha_emision_end
			  FROM endedmae
			 WHERE no_poliza = _no_poliza
			   AND cod_endomov = '002'
			   AND vigencia_inic = _fecha_cancelacion
		 END FOREACH

		 IF  _fecha_emision_end <= _fecha_hasta THEN
			CONTINUE FOREACH;
		 END IF
	  END IF
}	   
	select no_poliza,
		   no_documento,
		   vigencia_inic,
		   vigencia_final,
		   cod_subramo,
		   fecha_suscripcion,
		   cod_contratante
	  into _no_poliza,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_subramo,
		   _fecha_emision,
		   _cod_cliente
	  from emipomae
	 where cod_ramo = '008'
	   and (fecha_suscripcion >= _fecha_desde and fecha_suscripcion <= _fecha_hasta)
	   and actualizado = 1
	
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		
		select valor_contrato,
			   suma_asegurada
		  into _valor_contrato,
			   _suma_asegurada
		  from emifian1
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
		   
		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
		
		let _porc_retencion	= 0.00;
		let _porc_cesion	= 0.00;
		
		foreach
			select cod_contrato,
				   porc_partic_suma
			  into _cod_contrato,
				   _porc_partic_suma
			  from emireaco
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and no_cambio = _no_cambio
			
			select tipo_contrato
			  into _tipo_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;
			
			if _tipo_contrato = 1 then
				let _porc_retencion = _porc_retencion + _porc_partic_suma;
			else
				let _porc_cesion = _porc_cesion + _porc_partic_suma;
			end if
		end foreach
		
		insert into tmp_cufian(
				no_documento,	
				cod_subramo,
				cod_cliente,
				proyecto,
				valor_contrato,
				monto_afianzado,
				contrato_retencion,
				contrato_cesion,
				fecha_emision,
				vigencia_inic,
				vigencia_final
				)
				select _no_documento,
					   _cod_subramo,
					   _cod_cliente,
					   descripcion,
					   _valor_contrato,
					   _suma_asegurada,
					   _porc_retencion,
					   _porc_cesion,
					   _fecha_emision,
					   _vigencia_inic,
					   _vigencia_final
				  from emipode2
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;
	end foreach
end foreach

foreach
	select no_documento,	
		   cod_subramo,
		   cod_cliente,
		   --proyecto[1,255],
		   valor_contrato,
		   monto_afianzado,
		   contrato_retencion,
		   contrato_cesion,
		   fecha_emision,
		   vigencia_inic,
		   vigencia_final
	  into _no_documento,
		   _cod_subramo,
		   _cod_cliente,
		   --_proyecto,
		   _valor_contrato,
		   _suma_asegurada,
		   _porc_retencion,
		   _porc_cesion,
		   _fecha_emision,
		   _vigencia_inic,
		   _vigencia_final
	  from tmp_cufian
	  
	select nombre
	  into _nom_subramo
	  from prdsubra
	 where cod_ramo = '008'
	   and cod_subramo = _cod_subramo;
	
	select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;
	 
	if _cod_subramo in ('003','011','015','016','017','018') then
	   let _tipo = 'CUMPLIMIENTO';
	elif _cod_subramo = '020' then
	   let _tipo = 'ANTICIPO';
	elif _cod_subramo in ('004','019') then
	   let _tipo = 'PAGO';
	elif _cod_subramo = '005' then
	   let _tipo = 'JUDICIALES';
	else
	   let _tipo = 'OTRAS';
	end if
	 
	return _no_documento,
		   _nom_subramo,
		   _nom_cliente,
		   '',--_proyecto,
		   _valor_contrato,
		   _suma_asegurada,
		   _porc_retencion,
		   _porc_cesion,
		   _fecha_emision,
		   _vigencia_inic,
		   _vigencia_final,
		   _compania_nombre,
		   _tipo
		   with resume;
end foreach

--drop table tmp_cufian;
end
end procedure
