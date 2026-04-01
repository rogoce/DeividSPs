-- Reporte de Polizas de Nulidad
-- Creado : 10/07/2017 - Autor: Henry Giron
-- Modificado: 10/07/2017 - Autor: Henry Giron
-- SIS v.2.0 - d_cob_sp_cas115_dw1 - DEIVID, S.A. 
-- execute procedure sp_cas115(1)

drop procedure sp_cas118;
create procedure sp_cas118()
returning	varchar(50) 	as Contratante,
			char(20)		as Poliza,
			date 			as Vigencia_Inicial,
			date 			as Vigencia_Final,
			date 			as Fecha_Anulacion,
			varchar(10)		as tipo_poliza,
			varchar(50)		as Ramo,
			varchar(50) 	as Forma_de_Pago,
			varchar(50) 	as Corredor,
			varchar(50) 	as Grupo,
			varchar(50)		as Zona_Cobros,
			dec(16,2)		as Prima_Anulada; 

define _mensaje				varchar(250);
define _nombre_formapag		varchar(50);
define _nombre_ramo			varchar(50); 
define _nom_agente			varchar(50); 
define _nombre_cli			varchar(50);
define _cia_nombre			varchar(50); 
define _nom_grupo			varchar(50);
define _nom_zona			varchar(50);
define _desc_n_r			varchar(10);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _cod_campana			char(10);
define _no_poliza			char(10);
define _cod_formapag		char(5);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _cod_cobrador		char(3); 
define _cod_subramo			char(3); 
define _cod_ramo			char(3); 
define _prima_bruta			dec(16,2);
define _cnt_gestion			smallint;
define _holgura_nueva		smallint;
define _holgura_renov		smallint;
define _dias_nulidad		smallint;
define _cnt_cliente			smallint;
define _cliente_vip			smallint;
define _dias_resta      	smallint;
define _fronting	      	smallint;
define _cnt_holgura         integer;
define _error_isam			integer;
define _error				integer;
define _fecha_suscripcion	date;
define _fecha_primer_pago	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_inicio		date;
define _fecha_actual		date;
define _fecha_hasta		    date;
define _fecha_anulacion     date;


set isolation to dirty read;
 --set debug file to "sp_cas115.trc";
 --trace on;
begin
on exception set _error,_error_isam,_mensaje	
 	return _mensaje,
		   '',
		   null,
		   null,
		   null,
		   '',
		   '',
		   '',
		   '',
		   '',
		   '',
		   _error;
end exception

foreach
	select no_poliza,
		   no_documento,
		   prima_bruta,
		   fecha_emision
	  into _no_poliza,
		   _no_documento,
		   _prima_bruta,
		   _fecha_anulacion
	  from endedmae
	  where cod_endomov = '002'
	   and cod_tipocan = '037'
	   and actualizado = 1
	   and user_added = 'DEIVID'
	   and vigencia_inic_pol >= '18/07/2017'

	let _cnt_gestion = 0;

	select count(*)
	  into _cnt_gestion
	  from cobgesti
	 where no_poliza = _no_poliza
	   and user_added <> 'DEIVID'
	   and tipo_aviso <> 20
	   and date(fecha_gestion) <= _fecha_anulacion;

	if _cnt_gestion is null then
		let _cnt_gestion = 0;
	end if
	
	if _cnt_gestion <> 0 then
		continue foreach;
	end if
	
	select decode(nueva_renov,'N','NUEVA','R','REVONACION')
	  into _desc_n_r
	  from emipomae
	 where no_poliza = _no_poliza;

	select c.nombre,
		   e.vigencia_inic,
		   e.vigencia_fin,
		   r.nombre,
		   f.nombre,
		   a.nombre,
		   g.nombre,
		   z.nombre
	  into _nombre_cli,
		   _vigencia_inic,
		   _vigencia_final,
		   _nombre_ramo,
		   _nombre_formapag,
		   _nom_agente,
		   _nom_grupo,
		   _nom_zona
	  from emipoliza e, cliclien c, prdramo r, cobforpa f, cligrupo g,cobcobra z,agtagent a
	 where e.cod_pagador = c.cod_cliente
	   and e.cod_ramo = r.cod_ramo
	   and f.cod_formapag = e.cod_formapag
	   and g.cod_grupo = e.cod_grupo
	   and e.cod_agente = a.cod_agente
	   and a.cod_cobrador = z.cod_cobrador
	   and e.no_documento = _no_documento;

	return _nombre_cli,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_anulacion,
		   _desc_n_r,
		   _nombre_ramo,
		   _nombre_formapag,
		   _nom_agente,
		   _nom_grupo,
		   _nom_zona,
		   _prima_bruta with resume;
end foreach

end
end procedure;