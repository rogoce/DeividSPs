-- Procedimiento que marca la requis como autorizada y aumenta lo pagado para el control de chequeras

-- Creado    : 19/05/2006 - Autor: Armando Moreno.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

--DROP PROCEDURE sp_rwf54;

CREATE PROCEDURE "informix".sp_rwf54(a_no_tranrec char(10))
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
define _no_requis  		 char(10);
define _monto     		 dec(16,2);
define _usuario      	 char(8);
define _nt               char(10);
define _cod_tipotran     char(3);

SET ISOLATION TO DIRTY READ;
--a_no_requis char(10),a_monto dec(16,2),a_usuario char(8), a_nt char(10)
let _ctrl_flujo = 0;
let _monto_sum  = 0;
let _retorno    = 0; 

select no_requis,
       monto,
	   user_added,
	   transaccion,
	   cod_tipotran
  into _no_requis,
       _monto,
	   _usuario,
	   _nt,
	   _cod_tipotran
  from rectrmae
 where no_tranrec = a_no_tranrec;

if _cod_tipotran <> '004' then
	return 0;
end if

select cod_banco,
	   cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqchmae
 where no_requis = _no_requis;

SELECT monto_disponible,
	   monto_asignado,
	   control_flujo
  INTO _monto_disponible,
	   _monto_asignado,
	   _ctrl_flujo
  FROM chqchequ
 WHERE cod_banco    = _cod_banco
   AND cod_chequera = _cod_chequera;

if _monto <= 0 then
	return 0;
end if

if _ctrl_flujo = 1 then		  --control de flujo
	
	let _monto_sum = _monto_disponible;-- + _monto;

	if _monto_sum > _monto_asignado then  --se acabo el disponible
		let _valor    = 0;
		let _usuario = null;
		let _retorno  = 1;

		select correo_aviso
		  into _correo_aviso
		  from chqchequ
		 where cod_banco 	= _cod_banco
		   and cod_chequera = _cod_chequera;

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
		 where no_requis 	= _no_requis		--se aumente lo disponible pero solo de las marcadas.
		   and transaccion  = _nt;
	else
		let _valor = 1;

 --		update chqchequ
 --		   set monto_disponible = monto_disponible + _monto
 --		 where cod_banco 	= _cod_banco
 --		   and cod_chequera = _cod_chequera;

	end if

 --	update chqchmae
 --	   set autorizado     = _valor,
 --		   autorizado_por = _usuario
 --	 where no_requis 	  = _no_requis;

else
	return 0;
end if

Return _retorno;

END PROCEDURE
