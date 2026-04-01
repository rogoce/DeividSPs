-- *********************************************************************************************
-- Procedimiento que genera el reporte de cuenta 26410 honorarios y comisiones por pagar agente
-- Creado : Armando Moreno Montenegro Fecha: 06/10/2022
-- *********************************************************************************************

DROP PROCEDURE sp_sac256;
CREATE PROCEDURE sp_sac256(a_anio CHAR(4), a_mes smallint)
RETURNING char(5),char(50),char(10),char(22),char(30),DEC(16,2);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);
define v_periodo,v_periodo1,v_periodo2,v_periodo4    char(4);
define v_aux_terc   char(5);
define v_nom_terc   varchar(50);
define v_saldo_ant,v_saldo_ant1,v_saldo_ant2,v_saldo_ant3,v_monto  dec(16,2);
define _cuenta,_no_lic      char(10);
define _estatus_lic         char(1);
define _cedula              char(30);
define _est_lic_char        char(22);

set isolation to dirty read;
begin 

--A = Activa
--P = Suspension Permanente
--T = Suspension Temporal
--X = Susp. Superintendencia

FOREACH EXECUTE PROCEDURE sp_sac167('01','26410','*',a_anio,a_mes,'sac')
INTO v_periodo,
     v_aux_terc,
	 v_nom_terc,
	 v_saldo_ant,
	 v_saldo_ant1,
	 v_saldo_ant2,
	 v_saldo_ant3,
	 v_monto,
	 v_periodo4,
	 v_periodo1,
	 v_periodo2,
	 _cuenta

	--call sp_sac167('01','26410','*',a_anio,a_mes,'sac') returning v_periodo,v_aux_terc,v_nom_terc,v_saldo_ant,v_saldo_ant,v_saldo_ant,v_saldo_ant,v_monto,v_periodo,v_periodo,v_periodo,_cuenta;
	let v_aux_terc = '0' || v_aux_terc[2,5];
   
	select no_licencia,estatus_licencia,cedula,nombre 
	  into _no_lic,_estatus_lic,_cedula,v_nom_terc
	  from agtagent
	 where cod_agente = v_aux_terc;
	 
	if _estatus_lic = 'A' then 
		let _est_lic_char = 'ACTIVA';
	elif _estatus_lic = 'P' then 
		let _est_lic_char = 'SUSP. PERMANENTE';
	elif _estatus_lic = 'T' then 
		let _est_lic_char = 'SUSP. TEMPORAL';
	else
		let _est_lic_char = 'SUSP. SUPERINTENDENCIA';
    end if	
	 
	return v_aux_terc,v_nom_terc,_no_lic,_est_lic_char,_cedula,v_monto with resume; 
	
end foreach;
end
end procedure
