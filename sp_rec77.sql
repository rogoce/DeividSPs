-- Incurrido Bruto Mayor de $10,000.00

-- Creado    : 19/11/2003 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - uof_actualiza_reclamos - uo_recl_validar_m - DEIVID, S.A.

--drop procedure sp_rec77;

create procedure sp_rec77(a_no_tranrec char(10)
) returning date,
			char(10),
			char(100),
			dec(16,2);

define _no_reclamo      char(10);
define _porc_coas       decimal(16,4);
define _monto           decimal(16,2);
define _variacion       decimal(16,2);
define _monto_bruto     decimal(16,2);

define _cod_tipotran    char(3);

SET ISOLATION TO DIRTY READ;

-- Informacion de Coseguro

SELECT porc_partic_coas
  INTO _porc_coas
  FROM reccoas
 WHERE no_reclamo   = _no_reclamo
   AND cod_coasegur = "036";

IF _porc_coas IS NULL THEN
	LET _porc_coas = 0;
END IF

-- Incurrido Bruto de la Transaccion

select no_reclamo,
       cod_tipotran,
	   monto,
	   variacion
  into _no_reclamo,
       _cod_tipotran,
	   _monto,
	   _variacion
  from rectrmae
 where no_tranrec = _no_tranrec;

if cod_tipotran = '004' or
   cod_tipotran = '005' or
   cod_tipotran = '006' or
   cod_tipotran = '007' then

	let _monto_bruto = _monto;

else

	let _monto_bruto = _monto;

end if


let _monto_bruto = (_monto + _variacion) / 100 * _porc_coas;

if _monto_bruto


end procedure
