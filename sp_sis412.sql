-- Procedimiento para Verificar los filtros del programa de Avisos de cancelacion
-- para el sistema de Cobros para Avisos de Cancelacion Automatico
-- Creado    : 30/07/2013  Por: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis412;
CREATE PROCEDURE sp_sis412(a_cod_avican char (10))
RETURNING INTEGER, CHAR(100);

Define v_no_documento		 char(20);
Define v_no_poliza			 char(10);
Define v_cod_ramo			 char(3);
Define v_cod_formapag		 char(3);
Define v_cod_suc			 char(3);
Define v_cod_status			 char(1);
Define v_cod_zona			 char(3);
Define v_cod_agente			 char(5);
Define v_cod_area			 char(5);
Define v_cod_grupo			 char(5);
Define v_cod_pagos			 char(3);
Define _ramo				 char(3);
Define _formapag			 char(3);
Define _suc					 char(3);
Define _status				 char(1);
Define _zona				 char(3);
Define _agente				 char(5);
Define _area				 char(5);
Define _grupo				 char(5);
Define _pagos				 char(3);
Define _acreencia			 char(3);
Define _moros				 char(3);
Define v_cod_pagador		 char(10);
Define v_vigencia_inic		 date;
Define v_vigencia_fin		 date;
Define v_por_vencer			 dec(16,2);
Define v_exigible			 dec(16,2);
Define v_corriente			 dec(16,2);
Define v_monto_30			 dec(16,2);
Define v_monto_60			 dec(16,2);
Define v_monto_90			 dec(16,2);
Define v_monto_120			 dec(16,2);
Define v_monto_150			 dec(16,2);
Define v_monto_180			 dec(16,2);
Define v_saldo				 dec(16,2);
Define v_prima_bruta		 dec(16,2);
Define _cod_agente			 char(5);
Define _dia_cob				 smallint;
Define v_cod_acreencia		 smallint;
Define v_dia_cob1			 smallint;
Define v_dia_cob2			 smallint;
Define _error				 smallint;
Define _contador2			 integer; 
Define flag					 smallint;
Define _usuario1        	 char(8);
define _vcod_agente			 char(5);  
define _vnom_agente			 char(100);
define _vcod_formapag		 char(3);	
define _vnom_formapag		 char(50);	
define _vcod_division		 char(3);	
define _vnom_division		 char(50);
define _vcod_zona			 char(3);	
define _vnom_zona			 char(50);	
define _vcod_Supervisor		 char(3);	
define _vnom_supervisor		 char(50);	
define _vusuario_supervisor	 char(8);	
define _vcod_Gestor			 char(3);	
define _vnom_gestor			 char(50);	
define _vusuario_gestor		 char(8);	
define _r_ow				 smallint;
define _repetido             char(50);	
define _veces				 smallint;
define _cod_tipoprod 		 char(3);


--set debug file to "sp_cob757.trc";
--trace on;

set isolation to dirty read;

Select filt_acre,
	   filt_agente,
	   filt_area,
	   filt_diacob,
	   filt_formapag,
	   filt_grupo,
	   filt_moros,
	   filt_pago,
	   filt_ramo,
	   filt_status,
	   filt_sucursal,
	   filt_zonacob,
	   usuario1
  into _acreencia,
       _agente,_area,
       _dia_cob,
       _formapag,
       _grupo,
       _moros,
       _pagos,
       _ramo,
       _status,
       _suc,
       _zona,
       _usuario1
  from avicanpar 
 where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 2;

if _moros = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Morosidad .";
elif _moros = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Morosidad .";
end if

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 1;

if _ramo = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Ramo.";
elif _ramo = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Ramo.";
end if

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 3;

if _formapag = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Forma de Pago .";
elif _formapag = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Forma de Pago .";
end if


select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 4;

if _zona = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Zona de Cobro .";
elif _zona = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Zona de Cobro .";
end if


select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 5;

if _agente = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Corredor .";
elif _agente = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Corredor .";
end if


select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 6;

if _suc = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Sucursal .";
elif _suc = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Sucursal .";
end if


select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 7;

if _area = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Area .";
elif _area = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Area .";
end if

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 8;

if _status = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Estatus .";
elif _status = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Estatus .";
end if

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 9;

if _grupo = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Grupo .";
elif _grupo = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Grupo .";
end if

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 10;

if _dia_cob = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Dias Cobros .";
elif _dia_cob = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Dias Cobros .";
end if

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 11;

if _acreencia = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Acreencia .";
elif _acreencia = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Acreencia .";
end if

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 12;

if _pagos = "1" and _contador2 = 0 then
	return 1,"Falta de Informacion de filtro - Pagos .";
elif _pagos = "0" and _contador2 > 0 then
	return 1,"No debe haber Informacion de filtro - Pagos .";
end if

return 0,"";


end procedure
