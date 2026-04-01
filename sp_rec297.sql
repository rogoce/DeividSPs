-- Procedimiento de Verificación de las Cuentas de Reclamos para el cierre mensual (cuentas 221, 222, 553, 541 y 419)
-- Creado    : 22/12/2015- Autor: Román Gordón

drop procedure sp_rec297;
create procedure sp_rec297(
a_compania  char(3), 
a_agencia   char(3), 
a_periodo1  char(7), 
a_periodo2  char(7))
returning	char(20)		as no_siniestro,
            char(10)		as no_reclamo,
			char(10)		as transaccion,
            varchar(100)	as asegurado,
			dec(16,2)		as pagado,
			dec(16,2)		as deducible,	
			varchar(100)	as a_nombre,
            varchar(50)		as cobertura,			
			char(10)		as cod_agente,
            varchar(50)		as agente,	
            varchar(50)		as ramo,	
            varchar(50)		as tipo_pago,	
			char(20)		as poliza,
			char(10)		as nueva_renovada,
			dec(16,2)		as prima_suscrita,
			date			as fecha_suscripcion,
			date			as vigencia_inicial,
			date			as vigencia_final,
			date			as fecha_siniestro,
			date			as fecha_notificacion,
			char(10)		as tipo_auto,
			smallint		as ano_auto,
			char(10)		as estatus_reclamo,
			varchar(100)	as nombre_afectado,
			char(30)		as emisor,
			char(30)		as sucursal,
			varchar(50)		as ajustador,
			char(10)		as transaccion_anula;
     	
define _tri					varchar(255);
define v_ramo_nombre		varchar(50);
define _nom_cuenta			varchar(50);
define v_compania_nombre	varchar(50);
define _cuenta				char(18);
define _no_poliza			char(10);
define _ano					char(4);
define _cod_ramo			char(3);
define v_incurrido_bruto	dec(16,2);
define v_recupero_bruto		dec(16,2);
define v_pagado_bruto1, v_pagado_bruto1_d		dec(16,2);
define v_reserva_recup		dec(16,2);
define v_reserva_bruto		dec(16,2);
define v_incurrido_bru		dec(16,2);
define v_pagado_total		dec(16,2);
define v_pagado_bruto		dec(16,2);
define v_reserva_neto		dec(16,2);
define v_pagado_neto		dec(16,2);
define v_salv_bruto			dec(16,2);
define _monto_total			dec(16,2);
define _diferencia			dec(16,2);
define v_dec_bruto			dec(16,2);
define _saldo				dec(16,2);
define _ramo_sis			smallint;
define _mes					smallint;
define _no_tranrec,_anular_nt          char(10);
define _no_reclamo, _no_reclamo_d          char(10);
define _numrecla            char(20);
define _cod_asegurado       char(10);
define _fecha_siniestro     date;
define _fecha_notificacion  date;
define _estatus_reclamo     char(1);
define _cod_cobertura       char(5);
define _cod_tipopago        char(3);
define _nueva_renov	        char(1);
define _no_documento        char(20);
define _prima_suscrita      dec(16,2);
define _fecha_suscripcion   date;
define _vigencia_inic       date;
define _vigencia_final      date;
define _cod_agente          char(10);
define _asegurado           varchar(100);
define _cobertura           varchar(50);
define _agente              varchar(50);
define _ramo                varchar(50);
define _tipo_pago           varchar(50); 
define _no_unidad           char(5);
define _no_motor            char(30);
define _ano_auto            smallint;
define _uso_auto            char(1);
define _tercero             varchar(100);
define _cod_tercero         char(10);
define _a_nombre            varchar(100);
define _user_added          char(8);
define _usuario             char(30);
define _sucursal_origen     char(3);
define _sucursal            char(30);
define _ajust_interno       char(3);
define _ajustador           varchar(50);
define _transaccion         char(10);
define _contador            smallint;

let v_compania_nombre = sp_sis01(a_compania);

let _tri = sp_rec01d(a_compania, a_agencia, a_periodo1, a_periodo2);

let _ano = a_periodo1[1,4];
let _mes = a_periodo1[6,7];
let _contador = 0;

--set debug file to "sp_rec297.trc";
--trace on;

let _anular_nt = '';

foreach
	select no_reclamo,
	       pagado_bruto1 + deducible_bruto as monto
	  into _no_reclamo_d,
	       v_pagado_bruto1_d
	  from tmp_sinis
	 where cod_ramo in ('002','020','023')
	   and pagado_bruto1 + deducible_bruto <> 0
	 group by no_reclamo, monto
	having count(*) > 1

{	select count(*),
	       no_reclamo,
	       pagado_bruto1 + v_dec_bruto
	  into _contador,
	       _no_reclamo_d,
	       v_pagado_bruto1_d
	  from tmp_sinis
	 where cod_ramo in ('002','020','023')
	   and pagado_bruto1 <> 0
	 group by no_reclamo, pagado_bruto1
}
--if _contador > 1 then
--let _contador = 0;
foreach
	select no_tranrec,
	       no_reclamo,
		   numrecla,
		   cod_ramo,
		   no_poliza,
		   incurrido_bruto,
		   pagado_bruto,
		   reserva_bruto,
		   reserva_neto,
		   pagado_bruto1,
		   salvamento_bruto,
		   recupero_bruto,
		   deducible_bruto
	  into _no_tranrec,
	       _no_reclamo,
		   _numrecla,
		   _cod_ramo,	
           _no_poliza,		   
		   v_incurrido_bru,
		   v_pagado_bruto,
		   v_reserva_bruto,
		   v_reserva_neto,
		   v_pagado_bruto1,
		   v_salv_bruto,
		   v_recupero_bruto,
		   v_dec_bruto
	  from tmp_sinis 
	  where no_reclamo = _no_reclamo_d
	    and pagado_bruto1 = v_pagado_bruto1_d
--	 group by no_poliza, cod_ramo
--	 order by no_tranrec, cod_ramo

	let _saldo = 0.00;

	-- Siniestros Pagados Cuenta 541
	let _saldo = 0.00;

	if v_pagado_bruto1 is null then
		let v_pagado_bruto1 = 0.00;
	end if

	if v_dec_bruto is null then
		let v_dec_bruto = 0.00;
	end if
	
	if (v_pagado_bruto1 + v_dec_bruto) <> 0.00 then
		select cod_asegurado,
		       fecha_siniestro,
			   fecha_documento,
			   estatus_reclamo,
			   no_unidad,
			   no_motor,
			   ajust_interno
		  into _cod_asegurado,
		       _fecha_siniestro,
			   _fecha_notificacion,
			   _estatus_reclamo,
			   _no_unidad,
			   _no_motor,
			   _ajust_interno
		  from recrcmae
		 where no_reclamo = _no_reclamo;
		 
		foreach		 
			select cod_cobertura
			  into _cod_cobertura
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and monto <> 0
			exit foreach;
		end foreach
		   
		select cod_tipopago,
               cod_cliente,
               transaccion,
			   anular_nt			   
          into _cod_tipopago,
		       _cod_tercero,
			   _transaccion,
			   _anular_nt
          from rectrmae 
         where no_tranrec = _no_tranrec;
		 
		let _tercero = null; 
		 
		if _cod_tipopago = '004' then
			select nombre
			  into _tercero
			  from cliclien
			 where cod_cliente = _cod_tercero;
		end if
		
		select nombre
		  into _a_nombre
		  from cliclien
		 where cod_cliente = _cod_tercero;

        select nueva_renov,
		       no_documento,
			   prima_suscrita,
			   fecha_suscripcion,
			   vigencia_inic,
			   vigencia_final,
               user_added,
               sucursal_origen			   
          into _nueva_renov,	
               _no_documento,
			   _prima_suscrita,
			   _fecha_suscripcion,
			   _vigencia_inic,
			   _vigencia_final,
               _user_added,
               _sucursal_origen			   
          from emipomae
         where no_poliza = _no_poliza;	

        select ano_auto
          into _ano_auto
          from emivehic
         where no_motor = _no_motor;

        select uso_auto
          into _uso_auto
          from emiauto
         where no_poliza = _no_poliza 
           and no_unidad = _no_unidad;		 
		   
		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			exit foreach;
		end foreach
		
		select nombre
		  into _asegurado
		  from cliclien
		 where cod_cliente = _cod_asegurado;
		 
		select nombre
		  into _cobertura
		  from prdcober
		 where cod_cobertura = _cod_cobertura;
		 
		select nombre
		  into _agente
		  from agtagent
		 where cod_agente = _cod_agente;
		 
		select nombre
		  into _ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;
		 
		select nombre
		  into _tipo_pago
		  from rectipag
		 where cod_tipopago = _cod_tipopago;
		 
		select descripcion
		  into _usuario
		  from insuser
		 where usuario = _user_added;
		 
		if _usuario is null or trim(_usuario) = "" then
			let _usuario = _user_added;
		end if
		 
		select descripcion
		  into _sucursal
		  from insagen
		 where codigo_compania = a_compania
		   and codigo_agencia = _sucursal_origen;
		   
		select nombre
		  into _ajustador
		  from recajust
		 where cod_ajustador = _ajust_interno;
		 
		return _numrecla,
		       _no_reclamo,
			   _transaccion,
		       _asegurado,
		       v_pagado_bruto1 + v_dec_bruto,
			   v_dec_bruto,
			   _a_nombre,
			   _cobertura,
			   _cod_agente,
			   _agente,
			   _ramo,
			   _tipo_pago,
			   _no_documento,
			   (case when _nueva_renov = "N" then "NUEVA" else "RENOVADA" end),
			   _prima_suscrita,
			   _fecha_suscripcion,
			   _vigencia_inic,
			   _vigencia_final,
			   _fecha_siniestro,
			   _fecha_notificacion,
			   (case when _uso_auto = "P" then "PARTICULAR" else "COMERCIAL" end),
			   _ano_auto,
			   (case when _estatus_reclamo = "A" then "ABIERTO" else (case when _estatus_reclamo = "C" then "CERRADO" else (case when _estatus_reclamo = "D" then "DECLINADO" else "NO APLICA" end) end) end),
			   _tercero,
			   _usuario,
			   _sucursal,
			   _ajustador,
			   _anular_nt
			   with resume;
	
	end if

end foreach
--end if
end foreach
drop table tmp_sinis;
end procedure;