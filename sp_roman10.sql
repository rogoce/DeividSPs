--Detalle de reclamos, correo Roman 28/05/2024
--Armando Moreno M.

drop procedure sp_roman10;
create procedure sp_roman10(a_periodo_desde char(7), a_periodo_hasta char(7))
returning	smallint	as anio,
			char(20)	as no_documento,
			char(1)     as tipo_poliza,
			char(5)		as no_unidad,               
			char(10)	as cod_contratante,
			char(10)    as placa,
			char(18)    as reclamo,
			char(5)     as cod_cobertura,
			varchar(50) as nom_cobertura,
			char(2)     as perd_total,
			char(50)    as evento,
			char(5)		as cod_producto,            
			varchar(50)	as nom_producto,
			date		as fecha_siniestro,
			char(20)	as estatus_reclamo,
			date		as fecha_pagado,
			char(1)		as sexo,
			smallint	as anio_auto,
			varchar(50) as marca,
			varchar(50) as modelo,
			varchar(50) as tipo_vehiculo,
			char(1)     as uso_auto,
			dec(16,2)   as suma_asegurada,
			dec(16,2)	as deducible,
			dec(16,2)	as pagado_total,
			dec(16,2)	as pagado_bruto,
			char(10)    as transaccion;

define v_filtros					char(255);
define _error_desc,_n_cobertura  	varchar(50);
define _n_tipo_vehi					varchar(50);
define _nom_producto,_n_evento		varchar(50);
define _n_marca, _n_modelo  		varchar(50);
define _no_motor                    varchar(30);
define v_desc_nombre				char(35);
define _estatus						char(20);
define _no_documento				char(20);
define _no_poliza,_placa,_anular_nt,_no_reclamo     char(10);
define _cod_contratante,_cod_reclamante char(10);
define v_nopoliza,_transaccion	char(10);
define _numrecla            char(18);
define _periodo    		    char(7);
define _cod_producto		char(5);
define _no_unidad			char(5);
define _cod_marca,_cod_cobertura  char(5);
define _cod_modelo			 char(5);
define _cod_evento,_cod_ramo,_cod_concepto,_cod_tipotran char(3);
define _perd_total          char(2);
define _cod_tipoveh			char(3);
define _sexo,_uso_auto,_tipo_pol  	char(1);
define _pagado_bruto,_monto,_descuenta_ded		dec(16,2);
define _pagado_total,_deducible,_ded,_monto_tran		dec(16,2);
define _suma_asegurada,_monto_concepto,_deducible_devuel		dec(16,2);
define _anio,_tipo_concepto,_tipo_transaccion                smallint;
define _ano_auto,_dia,_mes  smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_reclamo,_fecha_siniestro,_fecha_pagado	date;

SET ISOLATION TO DIRTY READ;
begin
on exception set _error, _error_isam, _error_desc
   return _error,'',_error_desc,'','','','','','','','','','','01/01/1900','','01/01/1900','',0,'','','','',0.00, 0.00,0.00,0.00,'';
end exception

drop table if exists tmp_sinis;
let v_filtros = sp_rec704('001','001',a_periodo_desde,a_periodo_hasta,'*','*','020,002,023;','*','*','*','*','*'); --Crea tabla tmp_sinis

--set debug file to "sp_roman10.trc";
--trace on;
foreach
	select trx.periodo[1,4] as anio,
	       trx.periodo,
		   trx.transaccion,
		   trx.anular_nt,
		   emi.no_documento,
		   rec.cod_asegurado,
		   rec.cod_reclamante,
		   rec.numrecla,
		   cob.cod_cobertura,
		   cob.nombre as cob,
		   decode(rec.perd_total,0,'No',1,'Si') as Perd_Total,
		   rec.cod_evento as evento,
		   prd.cod_producto,
		   prd.nombre,
		   rec.fecha_siniestro,
		   decode(rec.estatus_reclamo,'C','Cerrado','A','Abierto','D','Declinado','N','No Aplica'),
		   trx.fecha,
		   tco.monto,
		   rec.no_unidad,
		   rec.no_poliza,
		   rec.suma_asegurada,
		   emi.cod_ramo,
		   trx.fecha_pagado,
		   rec.no_reclamo
	  into _anio,
	       _periodo,
		   _transaccion,
		   _anular_nt,
		   _no_documento,
		   _cod_contratante,
		   _cod_reclamante,
		   _numrecla,
		   _cod_cobertura,
		   _n_cobertura,
		   _perd_total,
		   _cod_evento,
		   _cod_producto,
		   _nom_producto,
		   _fecha_siniestro,
		   _estatus,
		   _fecha_reclamo,
		   _monto,
		   _no_unidad,
		   _no_poliza,
		   _suma_asegurada,
		   _cod_ramo,
		   _fecha_pagado,
		   _no_reclamo
      from rectrmae trx
	 inner join recrcmae rec on rec.no_reclamo = trx.no_reclamo
	 inner join emipomae emi on emi.no_poliza = rec.no_poliza
	 inner join emipouni uni on uni.no_poliza = rec.no_poliza and uni.no_unidad = rec.no_unidad
	 inner join rectipag tip on tip.cod_tipopago = trx.cod_tipopago
	 inner join rectrcob tco on tco.no_tranrec = trx.no_tranrec
	 inner join prdcober cob on cob.cod_cobertura = tco.cod_cobertura
	 inner join prdprod prd on prd.cod_producto = uni.cod_producto
	 where trx.cod_tipotran = '004'
	   and trx.periodo between a_periodo_desde and a_periodo_hasta
	   and trx.actualizado = 1
	   and emi.cod_ramo in('002','023','020')
	   and tco.monto <> 0
	 order by rec.numrecla  
	
	let _ded = 0.00;
	let _monto_tran = 0.00;
	
	FOREACH
		 SELECT monto,
				cod_tipotran
		   INTO _monto_tran,
				_cod_tipotran
		   FROM rectrmae
		  WHERE no_reclamo   = _no_reclamo
		    AND actualizado  = 1

		 SELECT tipo_transaccion
		   INTO _tipo_transaccion
		   FROM rectitra
		  WHERE cod_tipotran = _cod_tipotran;

		 IF _tipo_transaccion = 7 THEN	--ded
			LET _ded = _ded + (_monto_tran * -1);
		 END IF
	END FOREACH;
	   
	if _cod_ramo = '023' then
		let _tipo_pol = 'C';
	else
		let _tipo_pol = 'I';
	end if
	   
	select sexo
	  into _sexo
	  from cliclien
	 where cod_cliente = _cod_contratante;
	 
	select nombre
	  into _n_evento
	  from recevent
	 where cod_evento = _cod_evento;
	 
	select no_motor,
		   cod_tipoveh,
		   uso_auto
	  into _no_motor,
		   _cod_tipoveh,
		   _uso_auto
	  from emiauto
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	select placa,
		   ano_auto,
		   cod_marca,
		   cod_modelo
	  into _placa,
		   _ano_auto,
		   _cod_marca,
		   _cod_modelo
	  from emivehic
	 where no_motor = _no_motor;
  
	select sum(pagado_bruto),
		   sum(pagado_total)
	  into _pagado_bruto,
		   _pagado_total
	  from tmp_sinis tmp
	 inner join recrcmae rec on rec.no_reclamo = tmp.no_reclamo 
	 inner join rectrmae trx on trx.no_tranrec = tmp.no_tranrec
	 where rec.no_poliza = _no_poliza
	   and rec.no_unidad = _no_unidad
	   and rec.cod_reclamante = _cod_contratante
	   and trx.periodo[1,4]   = _anio
	   and tmp.seleccionado   = 1;
	   
	if _pagado_total is null then
		let _pagado_total = 0.00;
	end if
	
	if _pagado_bruto is null then
		let _pagado_bruto = 0.00;
	end if
	
	select nombre
	  into _n_marca
	  from emimarca
	 where cod_marca = _cod_marca;
	
	select nombre
	  into _n_modelo
	  from emimodel
	 where cod_modelo = _cod_modelo;
	 
	select nombre
	  into _n_tipo_vehi
	  from emitiveh
	 where cod_tipoveh = _cod_tipoveh;
	 
	--CONCEPTO DE PAGO
	let _deducible        = 0.00;
	let _deducible_devuel = 0.00;
	let _descuenta_ded    = 0.00;
	FOREACH
		SELECT c.cod_concepto,
	    	   SUM(c.monto)
		  INTO _cod_concepto,
	           _monto_concepto
	      FROM rectrcon c, rectrmae t
	     WHERE c.no_tranrec   = t.no_tranrec
		   AND t.numrecla     = _numrecla
		   AND t.actualizado  = 1
		   and t.periodo[1,4] = _anio
		 GROUP BY cod_concepto

		  IF _monto_concepto IS NULL THEN
		  	LET _monto_concepto = 0;
		  END IF

		SELECT tipo_concepto
		  INTO _tipo_concepto
		  FROM recconce
		 WHERE cod_concepto = _cod_concepto;

	   	IF _tipo_concepto = 2 THEN	--desc. ded.
			LET _descuenta_ded = _monto_concepto;
		END IF

	   	IF _tipo_concepto = 3 THEN	--devol. de ded.
			LET _deducible_devuel = _monto_concepto;
		END IF

		LET _deducible = _ded + _descuenta_ded + _deducible_devuel;
	END FOREACH;

	LET _deducible = _deducible * -1;

	return _anio,
		   _no_documento,
		   _tipo_pol,
		   _no_unidad,
		   _cod_contratante,
		   _placa,
		   _numrecla,
		   _cod_cobertura,
		   _n_cobertura,
		   _perd_total,
		   _n_evento,
		   _cod_producto,
		   _nom_producto,
		   _fecha_siniestro,
		   _estatus,
		   _fecha_pagado,
		   _sexo,
		   _ano_auto,
		   _n_marca,
		   _n_modelo,
		   _n_tipo_vehi,
		   _uso_auto,
		   _suma_asegurada,
		   _deducible,
		   _pagado_total,
		   _pagado_bruto,
		   _transaccion
		   with resume;
end foreach
end
end procedure;