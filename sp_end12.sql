-- Procedimiento para generar reporte de los endosos de tecnica de seguro.
-- Creado    : 29/08/2014 - Autor: Federico Coronado 

drop procedure sp_end12;

create procedure "informix".sp_end12()
returning	char(20),
			date,
			date,
			varchar(10),
			varchar(50),
			varchar(50),
			varchar(1),
			date,
			varchar(5),
			varchar(5),
			decimal(16,2),
			decimal(16,2),
			decimal(16,2),
			decimal(16,2),
			decimal(16,2),
			varchar(7);

--- Actualización del endoso

define v_no_poliza					varchar(10);
define v_no_endoso					varchar(5);
define v_no_documento				varchar(20);
define v_vigencia_inic				date;
define v_vigencia_final				date;
define v_cod_ramo                   varchar(10);
define v_cliente_nom                varchar(50);
define v_tipo_persona               char(1);
define v_cedula                     varchar(50);
define v_fecha_aniversario          date;
define v_cod_contratante            varchar(10);
define v_no_unidad					varchar(5);
define v_cod_producto               varchar(5);
define v_prima						decimal(16,2);
define v_descuento                  decimal(16,2);
define v_prima_neta                 decimal(16,2);
define v_impuesto                   decimal(16,2);
define v_prima_bruta                decimal(16,2);
define v_observacion                varchar(10);
define v_periodo                    varchar(7);

--set debug file to "sp_end09.trc"; 
--trace on;

set lock mode to wait;
begin

	let v_cod_ramo = 'Vida Col';
	foreach
		select a.no_poliza,
			   no_endoso, 
			   a.no_documento, 
			   c.vigencia_inic, 
			   c.vigencia_final,
			   c.cod_contratante,
			   a.periodo
		 into  v_no_poliza,
			   v_no_endoso,
			   v_no_documento,
			   v_vigencia_inic,
			   v_vigencia_final,
			   v_cod_contratante,
			   v_periodo
		  from endedmae a inner join emipoagt b	on a.no_poliza = b.no_poliza
	inner join emipomae c on b.no_poliza = c.no_poliza
		 where cod_agente      = '00180'
		   and a.vigencia_inic >= '01/01/2016'
           and a.vigencia_inic <= '01/01/2017'
		   and cod_ramo        = '016'
		   and c.cod_grupo     = '01016'
		   and cod_endomov in('006','011')
	  order by a.periodo
	  
	     select nombre,
				tipo_persona,
				fecha_aniversario,
				cedula
		   into v_cliente_nom,
				v_tipo_persona,
				v_fecha_aniversario,
				v_cedula
		   from cliclien
		  where cod_cliente = v_cod_contratante;
		  
		foreach
			select no_unidad,
				   cod_producto,
				   prima,
				   descuento,
				   prima_neta,
				   impuesto,
				   prima_bruta
			  into v_no_unidad,
				   v_cod_producto,
				   v_prima,
				   v_descuento,
				   v_prima_neta,
				   v_impuesto,
				   v_prima_bruta
			 from endeduni 
			where no_poliza = v_no_poliza
			  and no_endoso = v_no_endoso
/*			
			if trim(v_no_unidad) = '00001' then
				let v_observacion = '2.50';
			elif trim(v_no_unidad) = '00002' then
				let v_observacion = '6.00/8.00';
			elif trim(v_no_unidad) = '00003' then
				let v_observacion = '4.50';
			elif trim(v_no_unidad) = '00004' then
				let v_observacion = '8.00';
			elif trim(v_no_unidad) = '00005' then
				let v_observacion = '14.00';
			end if
*/	 
		return v_no_documento,
			   v_vigencia_inic,
			   v_vigencia_final,
			   v_cod_ramo,
			   v_cedula,
			   v_cliente_nom,
			   v_tipo_persona,
			   v_fecha_aniversario,
			   v_no_unidad,
			   v_cod_producto,
			   v_prima,
			   v_descuento,
			   v_prima_neta,
			   v_impuesto,
			   v_prima_bruta,
			   v_periodo
			   with resume;
		end foreach
	end foreach
end
end procedure;