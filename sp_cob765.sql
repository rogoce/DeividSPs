-- Procedimiento que carga una poliza en Avicanpar y Avicanfil
-- Creado    : 31/10/2010 -- Autor: Henry Giron
-- execute procedure sp_cob765("0211-00100-01","HGIRON")
drop procedure sp_cob765;
create procedure "informix".sp_cob765(a_poliza char(20),a_usuario char(10) default "JMILLER")
returning	integer,char(255);
define _error				 integer;
define _error_desc			 char(255);
define _error_isam			 integer;
define _cod_avican			 char(10);
define _nombre				 char(100);
define _fecha_desde			 date;
define _fecha_hasta			 date;
define _tipo_avican			 integer;
define _estatus				 smallint;
define _date_added			 date;
define _user_added			 char(8);
define _filt_ramo			 smallint;
define _filt_moros			 smallint;
define _filt_formapag		 smallint;
define _filt_zonacob		 smallint;
define _filt_agente			 smallint;
define _filt_sucursal		 smallint;
define _filt_area			 smallint;
define _filt_status			 smallint;
define _filt_pago			 smallint;
define _filt_acre			 smallint;
define _filt_grupo			 smallint;
define _filt_diacob			 smallint;
define _firma1				 char(10);
define _firma2				 char(10);
define _tm_ultima_gestion	 integer;
define _tm_fecha_efectiva	 integer;
define _nombre1				 char(50);
define _cargo1				 char(50);
define _usuario1			 char(10);
define _nombre2				 char(50);
define _cargo2				 char(50);
define _usuario2			 char(10);
--define _cod_avican			 char(10);
define _tipo_filtro			 char(1);
define _cod_filtro			 char(5);
define _descripcion			 char(50);
define _ramo_nom			 char(50);
define _ramo_sis             smallint;
define _no_documento		 char(20);
define _cod_ramo			 char(3);
define _cod_formapag		 char(10);
define _cod_area			 char(10);
define _cod_grupo			 char(5);
define _cod_pagos			 smallint;
define _cod_pagador		     char(8);
define _cod_suc			     char(1);
define _dia_cob1			 integer;
define _dia_cob2			 integer;
define _cod_status			 integer;
define _vigencia_inic		 char(255);
define _vigencia_fin		 integer;
define _estatus_par          smallint;
define _exigible			 DECIMAL(16,2);
define _por_vencer			 DECIMAL(16,2);
define _corriente			 DECIMAL(16,2);
define _monto_30			 DECIMAL(16,2);
define _monto_60			 DECIMAL(16,2);
define _monto_90			 DECIMAL(16,2);
define _monto_120			 DECIMAL(16,2);
define _monto_150			 DECIMAL(16,2);
define _monto_180			 DECIMAL(16,2);
define _saldo				 DECIMAL(16,2);
define _cod_agente			 char(5);
define _cod_zona			 char(3);
define _cod_acreencia		 smallint;
define _prima_bruta		     DECIMAL(16,2);
define _periodo		         char(7);
define _ano_char	         char(4);
define _mes_char             char(2);
define _dia_char             char(2);
define _cod_Supervisor		 char(3);
define _nom_supervisor		 char(50);
define _usuario_supervisor	 char(10);
define _cargo_supervisor	 char(50);
define _cod_Gestor			 char(3);
define _nom_gestor			 char(50);
define _usuario_gestor		 char(10);
define _cargo_gestor		 char(50);
define _no_poliza,_no_poliza2          char(10);
define _estatus_poliza       char(1);
define _ver_error			 smallint;
define _ver_msj			     char(255);


{    cascampana		avicanpar
  cascampanafil		avicanfil
      campoliza		avicanpoliza  }

 on exception set _error
    --rollback work;
    return _error,_error_desc;
end exception

set isolation to dirty read;
--return 0,"Actualizacion Satisfactoria.";

 let _cod_avican = "";
 let _fecha_desde = today;
 let _fecha_hasta = today;
 let _tipo_avican = 1;
 let _estatus = 0;
 let _date_added = today;
 let _user_added = a_usuario;
 let _estatus_par = 2;--se coloca Activo
 let _filt_ramo = 0;
 let _filt_moros = 1;
 let _filt_formapag = 0;
 let _filt_zonacob = 0;
 let _filt_agente = 0;
 let _filt_sucursal = 0;
 let _filt_area = 0;
 let _filt_status = 0;
 let _filt_pago = 0;
 let _filt_acre = 0;
 let _filt_grupo = 0;
 let _filt_diacob = 0;
 let _firma1 = "";
 let _firma2 = ""; 
 let _tm_ultima_gestion = "";
 let _tm_fecha_efectiva = ""; 
 let _nombre1 = ""; 
 let _cargo1 = ""; 
 let _usuario1 = ""; 
 let _nombre2 = ""; 
 let _cargo2 = ""; 
 let _usuario2 = ""; 
 let _cod_avican = ""; 
 let _tipo_filtro = ""; 
 let _cod_filtro = ""; 
 let _descripcion = ""; 
 let _estatus_poliza = "";

--set debug file to "sp_cob765.trc";
--trace on;

if  day(today) < 10 then
	let _dia_char = '0'||day(today);
else
	let _dia_char = day(today);
end if

if  month(today) < 10 then
	let _mes_char = '0'||month(today);
else
	let _mes_char = month(today);
end if

let _ano_char	  = year(today);
let _periodo	  = _ano_char || "-" || _mes_char;

 if _cod_avican is null or _cod_avican = "" then
	let _cod_avican = sp_sis13("001", "COB", "02", "par_avican"); 
end if

delete from avisocanc    where no_aviso   = _cod_avican;
delete from avicanpoliza where cod_avican = _cod_avican;
delete from avicanfil    where cod_avican = _cod_avican;
delete from avicanpar    where cod_avican = _cod_avican;

select firma_end_canc
  into a_usuario
  from parparam
 where cod_compania = "001";

--LET a_usuario = 'MSOLIS';


--Parametros del filtro
call sp_sis154(a_usuario) returning _cod_Supervisor,
                                  	_nom_supervisor,
                                  	_usuario_supervisor,
                                  	_cargo_supervisor,
                                  	_cod_Gestor,
                                  	_nom_gestor,
                                  	_usuario_gestor,
                                  	_cargo_gestor; 

let _usuario2 			= _usuario_supervisor; 
let _nombre2  			= _nom_supervisor;
let _cargo2   			= _cargo_supervisor;	
let _nombre1  			= _nom_gestor;
let _cargo1   			= _cargo_gestor; 
let _tm_ultima_gestion 	= 2		   ;
let _tm_fecha_efectiva 	= 10	   ; 
let _no_poliza 			= sp_sis21(a_poliza);

 select trim(no_documento),trim(cod_ramo),estatus_poliza
   into	_no_documento, _cod_ramo, _estatus_poliza
   from	emipomae
  where	no_documento= trim(a_poliza)
    and no_poliza = _no_poliza;

 let _nombre = trim(a_poliza)||" - "||_dia_char||"/"||_mes_char||"/"||_ano_char;

    insert into avicanpar (
           cod_avican,
           nombre,
           fecha_desde,
           fecha_hasta,
           tipo_avican,
           estatus,
           date_added,
           user_added,
           filt_ramo,
           filt_moros,
           filt_formapag,
           filt_zonacob,
           filt_agente,
           filt_sucursal,
           filt_area,
           filt_status,
           filt_pago,
           filt_acre,
           filt_grupo,
           filt_diacob,
           firma1,
           firma2,
           tm_ultima_gestion,
           tm_fecha_efectiva,
           nombre1,
           cargo1,
           usuario1,
           nombre2,
           cargo2,
           usuario2) 	
   values (_cod_avican,
           _nombre,
           _fecha_desde,
           _fecha_hasta,
           _tipo_avican,
           _estatus_par,
           _date_added,
           _user_added,
           _filt_ramo,
           _filt_moros,
           _filt_formapag,
           _filt_zonacob,
           _filt_agente,
           _filt_sucursal,
           _filt_area,
           _filt_status,
           _filt_pago,
           _filt_acre,
           _filt_grupo,
           _filt_diacob,
           _firma1,
           _firma2,
           _tm_ultima_gestion,
           _tm_fecha_efectiva,
           _nombre1,
           _cargo1,
           _usuario1,
           _nombre2,
           _cargo2,
           _usuario2);

		-- 1 Ramo
		-- 2 Morosidad
		-- 3 Forma de pago
		-- 4 Zona
		-- 5 Corredor
		-- 6
		-- 7
		-- 8 Estatus

		select nombre,ramo_sis
		  into _ramo_nom,_ramo_sis
		  from prdramo
		 where trim(cod_ramo)  = trim(_cod_ramo);

		let _tipo_filtro = 1;
		let _cod_filtro  = trim(_cod_ramo);
		let _descripcion = trim(upper(_ramo_nom));

    insert into avicanfil(
           cod_avican,
           tipo_filtro,
           cod_filtro,
           descripcion)
   values (_cod_avican,
           _tipo_filtro,
           _cod_filtro,
           _descripcion);

		if _ramo_sis in (5,6,7,9) then -- mora a 60
			let _cod_filtro  = "003";
			let _descripcion = "60 Dias";
		else
			let _cod_filtro  = "004";
			let _descripcion = "90 Dias";
		end if

    insert into avicanfil(
           cod_avican,
           tipo_filtro,
           cod_filtro,
           descripcion)
   values (_cod_avican,
           _tipo_filtro,
           _cod_filtro,
           _descripcion);

	Select no_documento,
		   cod_ramo,
		   cod_formapag,
		   cod_area,   
		   cod_grupo,
		   cod_pagos,
		   cod_pagador,
		   cod_sucursal,
		   dia_cobros1,
		   dia_cobros2,
		   cod_status,
		   vigencia_inic,
		   vigencia_fin,
		   exigible,
		   por_vencer,
		   corriente,
		   monto_30,
		   monto_60,
		   monto_90,
		   monto_120,
		   monto_150,
		   monto_180,
		   saldo,
		   cod_acreencia,
		   cod_zona,
		   cod_agente,
		   prima_bruta
	  into _no_documento, 
		   _cod_ramo, 
		   _cod_formapag, 
		   _cod_area, 
		   _cod_grupo, 
		   _cod_pagos, 
		   _cod_pagador, 
		   _cod_suc, 
		   _dia_cob1, 
		   _dia_cob2, 
		   _cod_status, 
		   _vigencia_inic, 
		   _vigencia_fin, 
		   _exigible, 
		   _por_vencer, 
		   _corriente, 
		   _monto_30, 
		   _monto_60, 
		   _monto_90, 
		   _monto_120, 
		   _monto_150, 
		   _monto_180, 
		   _saldo, 
		   _cod_acreencia, 
		   _cod_zona, 
		   _cod_agente, 
		   _prima_bruta 
	  from emipoliza
	 where no_documento = trim(a_poliza);

  	   CALL sp_cob245("001","001",a_poliza,_periodo,today)
   	   RETURNING _por_vencer,
		 	   	 _exigible,
		 	   	 _corriente,
		 	   	 _monto_30,
		 	   	 _monto_60,
		 	   	 _monto_90,
		 	   	 _monto_120,
		 	   	 _monto_150,
		 	   	 _monto_180,
		 	   	 _saldo;

	insert into avicanpoliza(
	       no_documento,		 
		   cod_ramo,			 
		   cod_formapag,		 
		   cod_area,   			 
		   cod_grupo,			 
		   cod_pagos,			 
		   cod_pagador,			 
		   cod_sucursal,		 
		   dia_cobros1,			 
		   dia_cobros2,			 
		   cod_status,			 
		   vigencia_inic,		 
		   vigencia_fin,		 
		   exigible,			 
		   por_vencer,			 
		   corriente,			 
		   monto_30,			 
		   monto_60,			 
		   monto_90,			 
		   monto_120,			 
		   monto_150,			 
		   monto_180,			 
		   saldo,				 
		   cod_agente,			 
		   cod_zona,			 
		   cod_acreencia,		 
		   cod_avican,			 
		   prima_bruta)			 
	values(a_poliza,
		   _cod_ramo,
		   _cod_formapag,
		   _cod_area,
		   _cod_grupo,
		   _cod_pagos,
		   _cod_pagador,
		   _cod_suc,
		   _dia_cob1,
		   _dia_cob2,
		   _cod_status,
		   _vigencia_inic,
		   _vigencia_fin,
		   _exigible,
		   _por_vencer,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _monto_120,
		   _monto_150,
		   _monto_180,
		   _saldo,
		   _cod_agente,
		   _cod_zona,
		   _cod_acreencia,
		   _cod_avican,
		   _prima_bruta);	

--update avisocanc set filt_agente = 1 where cod_avican = '00082';

call sp_cob758(_cod_avican,a_usuario) returning _ver_error,_ver_msj;
if _ver_error = 0 then
	return 0,'Adicion de Registro Exitosa';
else
	return 1,'Error de Proceso';
end if

end procedure



			