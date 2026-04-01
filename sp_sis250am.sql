-- Determinar para las polizas de vida ramo 019, el numero de poliza interno.
--
-- Creado    : 27/06/2024 - Autor:Armando Moreno M.

--PARA PRUEBAS

DROP PROCEDURE sp_sis250am;
CREATE PROCEDURE sp_sis250am(a_no_documento char(20),a_periodo char(7),a_fecha date)
RETURNING char(10),SMALLINT;
		  
define _no_documento	char(20);
define _no_remesa,_no_pol_ult,_no_pol_ant char(10);
define _monto,v_por_vencer,v_exigible,v_corriente,v_monto_30,v_monto_45,v_monto_60,v_saldo,_prima_bruta dec(16,2);
define _vig_ini,_fecha_suscripcion,_fecha_menos date;
define _cod_ramo  char(3);


let _no_pol_ult = sp_sis21(a_no_documento);		--no_poliza ultima vigencia
let _no_pol_ant = sp_sis21am(a_no_documento);	--no_poliza vigencia anterior
		
select vigencia_inic,
	   fecha_suscripcion,
	   cod_ramo
  into _vig_ini,
	   _fecha_suscripcion,
	   _cod_ramo
  from emipomae
where no_poliza = _no_pol_ult;
		
let _fecha_menos = a_fecha - 1 units day;
call sp_cob33d('001','001',a_no_documento,a_periodo,_fecha_menos) returning v_por_vencer,v_exigible,v_corriente,v_monto_30,v_monto_45,v_monto_60,v_saldo;

if v_saldo = 0  OR _cod_ramo <> '019' then
	return _no_pol_ult,0;
end if
			
select sum(prima_bruta)
  into _prima_bruta
  from endedmae
 where actualizado   = 1
   and no_poliza     = _no_pol_ult
   and fecha_emision <= a_fecha;

if _prima_bruta is null then
	let _prima_bruta = 0;
end if   
			   
if a_fecha >= _fecha_suscripcion and a_fecha <= _vig_ini then
	return _no_pol_ant,1;
end if

if abs(v_saldo) > abs(_prima_bruta) and a_fecha > _vig_ini then
	return _no_pol_ant,2;
end if	
			 
return _no_pol_ult,3;

END PROCEDURE;
