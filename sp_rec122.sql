-- Procedimiento que marca la requis como autorizada y aumenta lo pagado para el control de chequeras

-- Creado    : 19/05/2006 - Autor: Armando Moreno.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

DROP PROCEDURE sp_rec122;

CREATE PROCEDURE sp_rec122(a_no_requis char(10),a_monto dec(16,2),a_usuario char(8), a_nt char(10))
returning integer;

define _no_poliza		 char(10);
define _cod_ramo         char(3);
define _cod_banco        char(3);
define _cod_chequera     char(3);
define _existe		     integer;
define _monto_disponible dec(16,2);
define _monto_asignado   dec(16,2);
define _monto_sum		 dec(16,2);
define _ctrl_flujo		 smallint;
define _valor			 smallint;
define _retorno			 smallint;
define _correo_aviso	 smallint;
define _cod_tipopago     char(3);
define _cod_tipotran     char(3);
define _cod_cliente      char(10);
define _periodo_pago     smallint;
define _firma_electronica smallint;
define _no_reclamo       char(10);
define _actual_potencial char(1);

SET ISOLATION TO DIRTY READ;

let _ctrl_flujo = 0;
let _monto_sum  = 0;
let _retorno    = 0;
let _periodo_pago = 1; 

select cod_banco,
	   cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqchmae
 where no_requis = a_no_requis;

SELECT monto_disponible,
	   monto_asignado,
	   control_flujo,
	   firma_electronica
  INTO _monto_disponible,
	   _monto_asignado,
	   _ctrl_flujo,
	   _firma_electronica
  FROM chqchequ
 WHERE cod_banco    = _cod_banco
   AND cod_chequera = _cod_chequera;

if a_monto <= 0 then
	return 0;
end if

if _ctrl_flujo = 1 then		  --control de flujo
	
	{let _monto_sum = _monto_disponible + a_monto;

	if _monto_sum > _monto_asignado then  --se acabo el disponible
		let _valor    = 0;
		let a_usuario = null;
		let _retorno  = 1;

		select correo_aviso
		  into _correo_aviso
		  from chqchequ
		 where cod_banco 	= _cod_banco
		   and cod_chequera = _cod_chequera;

    	set lock mode to wait 60;

		if _correo_aviso = 0 then
			update chqchequ
			   set correo_aviso = 1				 --marca para enviar correo por que se acabo el disponible de la chquera
			 where cod_banco 	= _cod_banco
			   and cod_chequera = _cod_chequera;
		else
			let _retorno  = 0;
		end if

		update chqchrec
		   set aumenta_disponible = 1			--se marca la transaccion para que cuando se ponga en cero el monto pagado
		 where no_requis 	= a_no_requis		--se aumente lo disponible pero solo de las marcadas.
		   and transaccion  = a_nt;

        set isolation to dirty read;

	else
    	set lock mode to wait 60;

		let _valor = 1;

		update chqchequ
		   set monto_disponible = monto_disponible + a_monto
		 where cod_banco 	= _cod_banco
		   and cod_chequera = _cod_chequera;

        set isolation to dirty read;
	end if}

	--Se debe setear periodo_pago en chqchmae de cliclien
	select cod_cliente,
	       cod_tipopago,
		   cod_tipotran
	  into _cod_cliente,
	       _cod_tipopago,
		   _cod_tipotran
	  from rectrmae
	 where transaccion = a_nt;

	if _cod_tipotran = "004" then  --Es Pago

		select periodo_pago,
		       actual_potencial
		  into _periodo_pago,
		       _actual_potencial
		  from cliclien
		 where cod_cliente = _cod_cliente;

        set lock mode to wait 60;

		if _periodo_pago = 0 and _cod_tipopago = "001" and _actual_potencial = "1" then	 --diario y sea proveedor

			let _periodo_pago = 1;

			update cliclien
			   set periodo_pago   = _periodo_pago
			 where cod_cliente 	  = _cod_cliente;
		end if
		if _periodo_pago = 2 then
			let _periodo_pago = 1;
		end if

		update chqchmae
		   set periodo_pago = _periodo_pago
		 where no_requis 	= a_no_requis;

        set isolation to dirty read;
	end if

    set lock mode to wait 60;

	let _valor = 1;

	update chqchmae
	   set autorizado     = _valor,
		   autorizado_por = a_usuario
	 where no_requis 	  = a_no_requis;

    set isolation to dirty read;

else
	if _firma_electronica = 1 then	 --> Cuando no se contempla lo de control de flujo y es firma electronica hay que setear el autorizado en 1
		select no_reclamo 
		  into _no_reclamo
		  from rectrmae
		 where transaccion = a_nt;

		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where no_reclamo = _no_reclamo;

		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		select count(*)
		  into _existe
		  from chqbanch
		 where cod_ramo = _cod_ramo;

		if _existe > 0 then
    		set lock mode to wait 60;

			update chqchmae				 --> para que el proceso diario lo pueda halar Amado 24/06/2009
			   set autorizado     = 1,
				   autorizado_por = a_usuario,
				   en_firma       = 4
			 where no_requis 	  = a_no_requis;

    		set isolation to dirty read;

	    end if
    end if
	return 0;
end if

Return _retorno;

END PROCEDURE
