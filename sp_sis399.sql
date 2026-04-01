--  Procedimiento para determinar si una poliza aplica o no para el descuento de pronto pago

-- Creado: 09/05/2012 - Autor: Armando Moreno M.

drop procedure sp_sis399;
create procedure sp_sis399(a_no_documento char(20))
returning smallint,char(50),decimal(16,2);


define _no_documento     char(20);
define _cod_formapag     char(3);
define _porc_rech        dec(16,2);
define _prima_nueva      dec(16,2);
define _vigencia_inic    date;
define _fecha_suscripcion   date;
define _cod_agente       char(5);
define _nombre_agente    varchar(50);
define _cod_asegurado    char(10);
define _nombre_asegurado varchar(100);
define _no_poliza        char(10);
define _nombre_producto  varchar(50);
define _cod_ramo         char(3);
define _cod_subramo      char(3);
define _no_pagos         smallint;
define _cant,_cant_rech	 smallint;
define _pagos            smallint;
define _chequera,_chequera2  char(3);
define v_existe_end      smallint;
define _prima_bruta      dec(16,2);
define _saldo            dec(16,2);
define _letra            dec(16,2);
define _pagos_tot,_result  smallint;

set isolation to dirty read;

let _no_pagos  = 0;
let _cant      = 0;
let _cant_rech = 0;
let _prima_bruta = 0;

--set debug file to "sp_sis395.trc";
--trace on;

    LET _no_poliza = sp_sis21(a_no_documento);

	SELECT fecha_suscripcion,
	       cod_ramo,
		   cod_formapag,
		   no_pagos,
		   cod_subramo,
		   prima_bruta
	  INTO _fecha_suscripcion,
		   _cod_ramo,
		   _cod_formapag,
		   _no_pagos,
		   _cod_subramo,
		   _prima_bruta
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	if _cod_ramo in('008','004','016','019','018','020') then  --Estos Ramos no aplican
		return 1,'RAMO NO APLICA',0;
	end if

    if _prima_bruta <= 100 then
		return 1,'ENDOSO NO APLICA, LA PRIMA ES MENOR DE B/.100.00',0;
	end if

	if _cod_formapag in('003','005') then	--Si es electronico tarjeta de credito y ach

		--Determinar cuantos pagos tiene electronicos
		SELECT count(*)
		  INTO _pagos
		  FROM cobredet d, cobremae m
		 WHERE d.actualizado  = 1
		   AND d.cod_compania = '001'
		   AND d.doc_remesa   = a_no_documento
		   AND d.tipo_mov     IN ('P','N')
		   AND d.no_remesa    = m.no_remesa
		   AND m.tipo_remesa  IN ('A', 'M', 'C')
		   AND d.fecha >= _fecha_suscripcion;

		if _pagos < 2 then
			return 1,'ENDOSO NO APLICA, NO TIENE MAS DE DOS PAGOS ELECTRONICO',0;
		end if
	end if

	SELECT count(*)
	  INTO v_existe_end
	  FROM endedmae
	 WHERE ( endedmae.no_poliza   = _no_poliza ) AND
		   ( endedmae.cod_endomov = "024" ) ;

	if v_existe_end > 0 then	--Ya se le aplico endoso de descuento de pronto pago
		return 1,'ENDOSO YA APLICADO',0;
	end if

	SELECT count(*)
	  INTO v_existe_end
	  FROM endedmae
	 WHERE ( endedmae.no_poliza   = _no_poliza ) AND
		   ( endedmae.cod_endomov = "025" ) ;

	if v_existe_end > 0 then	--Ya se le aplico endoso de Reversion de descuento de pronto pago
		return 1,'ENDOSO DE REVERSION DE DESCUENTO YA APLICADO',0;
	end if

	let _saldo = sp_cob115b('001','001',a_no_documento, "");

	if _saldo <= 0 then
		return 1,'TIENE SALDO MENOR O IGUAL A CERO',0;
	end if
					
	let v_existe_end = sp_pro861(_no_poliza);

    if 	v_existe_end = 1 then
		return 1,'NO APLICA ESTA POLIZA SODA',0;
	end if

	let v_existe_end = sp_pro857(_no_poliza);

    if 	v_existe_end = 1 then
		return 1,'ENDOSO NO APLICA, UBICACION EN ZONA LIBRE',0;
	end if

return 0,'SI APLICA',0;

end procedure