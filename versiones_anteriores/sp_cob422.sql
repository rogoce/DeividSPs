-- Reporte de Polizas con posibles cese
-- Creado : 20/08/2019- Autor: Henry Giron
-- Modificado: 20/08/2019- Autor: Henry Giron
-- SIS v.2.0 - d_cob_sp_cob422_dw1 - DEIVID, S.A. 
-- execute procedure sp_cob422(15,1)
drop procedure sp_cob422;
-- 23/09/2019 15:56
create procedure sp_cob422(a_dias_cese smallint default 0, a_camp_cese smallint default 1)
returning	char(20) 		as Poliza,
			char(10) 		as Cod_pagador,
			varchar(50) 	as Contratante,
			date 			as Fecha_Primer_Pago,
			date 			as Vigencia_Inicial,
			date 			as Vigencia_Final,
			char(5) 		as cod_formapag,
			varchar(50) 	as Forma_de_Pago,
			char(5) 		as cod_grupo,
			varchar(50) 	as Grupo,
			char(5) 		as cod_agente,
			varchar(50) 	as Corredor,
			char(3) 		as cod_cobrador,
			varchar(50)		as Zona_Cobros,
			char(5)			as cod_ramo,
			varchar(50)		as Ramo,
			dec(16,2)		as Prima_Bruta,
			varchar(20)		as Tipo_Poliza,	
			date			as Fecha_cese,
			char(10)		as cod_campana,
			varchar(50)		as campana,
			smallint		as Dias_resta,
			varchar(50)		as cia,
			smallint		as cliente_vip,
			date			as fecha_actual,
			date			as fecha_hasta,
			date			as Fecha_suspension; 

define _mensaje				varchar(250);
define _nombre_formapag		varchar(50);
define _nombre_aviso			varchar(50);
define _nombre_ramo			varchar(50); 
define _nom_agente			varchar(50); 
define _nombre_cli			varchar(50);
define _cia_nombre			varchar(50); 
define _nom_grupo			varchar(50);
define _nom_zona			varchar(50);
define _desc_n_r			varchar(10);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _cod_avican			char(10);
define _no_poliza			char(10);
define _cod_formapag		char(5);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _cod_cobrador		char(3); 
define _cod_subramo			char(3); 
define _cod_ramo			char(3); 
define _nueva_renov			char(1);
define _prima_bruta			dec(16,2);
define _estatus_poliza		smallint;
define _susp_anulacion		smallint;
define _holgura_nueva		smallint;
define _holgura_renov		smallint;
define _dias_cese		smallint;
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
define _fecha_cese          date;
define _fecha_suspension	date;


  drop table if exists tmp_avicanpoliza;
set isolation to dirty read;
 set debug file to "sp_cob422.trc";
 trace on;
 select * from avicanpoliza
  into temp tmp_avicanpoliza;
  
begin
on exception set _error,_error_isam,_mensaje	
 	return	'',
			'',
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
			'',
			'',
			'',
			'',
			0.00,
			'',
			null,
			'',
			'',
			_error,
			_mensaje,
			0,
			null,
			null,
			null;
end exception

let  _cia_nombre = sp_sis01('001'); 
let _fecha_actual = today;

if a_camp_cese = 1 then
	let _cod_avican = '00522';  -- 1-	ANC, PLA y electrÃ³nico, en todas las zonas de cobros en pÃ³lizas nuevas y renovadas. 
else	
	let _cod_avican = '00523';  -- 2-	COR, DUC, DCE, en todas las zonas de cobros en pÃ³lizas nuevas y renovadas.  Esto aplica para todas las pÃ³lizas que aplican para cese de coberturas.
end if	

delete from avicanpoliza where cod_avican = _cod_avican;
delete from avisocanc where no_aviso = _cod_avican;

let _desc_n_r = '';
let _cnt_holgura = 0;
let _error = 0;
let _holgura_nueva = 60;
let _holgura_renov = 60;

if a_dias_cese = 0 then

	select valor_parametro
	  into _dias_cese
	  from inspaag
	 where codigo_parametro = 'par_cese';  -- parametro de cese a 15 dias 
else 
	let _dias_cese = a_dias_cese; 
end if	

if _dias_cese is null or _dias_cese = 0 then 
	let _mensaje = "Valor de parametro de dias_Cese invalido.";
	return '','','',null,null,null,'','','','','','','','','','',0.00,'',null,'','',_error,_mensaje,0,null,null,null;
end if

let _fecha_hasta  = _fecha_actual + 7 units day; 

--let _fecha_inicio = '18/07/2017';
-- call sp_cob356(_fecha_inicio, 10)
--call sp_cob757(_cod_avican)  -- CampaÃ±a Automatica de CancelaciÃ³n para Ramos 002,020 posible aplicaion de cese 15 dias
call sp_cob424(_cod_avican,_fecha_actual,_dias_cese)
returning _error, _mensaje;

if _error <> 0 then
	return '','','',null,null,null,'','','','','','','','','','',0.00,'',null,'','',_error,_mensaje,0,null,null,null;
end if

--set debug file to "sp_cob422.trc";
--trace on;

foreach
	select b.cod_avican,
	       a.no_documento,						   
		   b.nombre
	  into _cod_avican,
		   _no_documento,
		   _nombre_aviso
	  from avicanpoliza a, avicanpar b
	 where a.cod_avican = b.cod_avican
	   and a.cod_avican = _cod_avican
	   and b.tipo_avican = 3  -- CampaÃ±a Cese
	   and b.estatus = 2      -- Activo
	   
	call sp_sis21(_no_documento) returning _no_poliza;
	
	select trim(no_documento),
	       cod_ramo,
		   cod_subramo,
		   cod_contratante,
	       vigencia_inic,
		   vigencia_final,
		   estatus_poliza,
		   nueva_renov,
		   (case when nueva_renov = 'N' then "NUEVA" else "RENOVADA" end) desc_n_r,
		   fecha_primer_pago,
		   fecha_suscripcion,
		   cod_grupo,
		   prima_bruta,
		   cod_formapag,
		   fronting,
		   _fecha_actual - fecha_primer_pago
	  into _no_documento,
	       _cod_ramo,
		   _cod_subramo,
		   _cod_cliente,
	       _vigencia_inic,
		   _vigencia_final,
		   _estatus_poliza,
		   _nueva_renov,
		   _desc_n_r,
		   _fecha_primer_pago,
		   _fecha_suscripcion,
		   _cod_grupo,
		   _prima_bruta,
		   _cod_formapag,
		   _fronting,
		   _dias_resta
	  from emipomae
	 where no_poliza = _no_poliza;
	  -- and vigencia_inic > _fecha_inicio;

	-- SE PUSO EN COMENTARIO PORQUE TODAS VALIDACIONES DE EXCEPIONES DE NULIDAD Y SUSPENSION DE COBERTURAS SON MANEJADAS POR EL SP_LEY003 --RomÃ¡n 30/10/2017
	if _estatus_poliza is null then
		continue foreach;
	end if	   

	call sp_ley003(_no_documento,1) returning _error,_mensaje;
	
	if _error < 0 then
		return '','','',null,null,null,'','','','','','','','','','',0.00,'',null,'','',_error,_mensaje,0,null,null,null;
	elif _error = 1 then
		continue foreach;
	end if

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 order by porc_partic_agt desc

		exit foreach;
	end foreach

	select nombre,
		   cod_cobrador
	  into _nom_agente,
		   _cod_cobrador
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into _nom_zona
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select trim(nombre)
	  into _nom_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	select trim(nombre)
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;	 

	select trim(nombre)
	  into _nombre_cli
	  from cliclien
	 where cod_cliente = _cod_cliente; 
	 
    select trim(nombre)
      into _nombre_formapag
      from cobforpa 
     where cod_formapag = _cod_formapag;
	 
	CALL sp_sis233 (_cod_cliente) returning _cliente_vip, _mensaje; 
	
    select fecha_suspension
	  into _fecha_suspension
	  from emipoliza
	 where no_documento = _no_documento;	
	 
	CALL sp_sis388a(_fecha_suspension,_dias_cese) returning _fecha_cese; 
	 
    return _no_documento,
	       _cod_cliente,
		   _nombre_cli,
	       _fecha_primer_pago,
           _vigencia_inic,
		   _vigencia_final,
		   _cod_formapag,
		   _nombre_formapag,
		   _cod_grupo,
		   _nom_grupo,
		   _cod_agente,
		   _nom_agente,
		   _cod_cobrador,
		   _nom_zona,
		   _cod_ramo,
		   _nombre_ramo,
		   _prima_bruta,
		   _desc_n_r,	
		   _fecha_cese, 
		   _cod_avican,
           _nombre_aviso,
		   _dias_resta,
		   _cia_nombre,
		   _cliente_vip,
		   _fecha_actual,
		   _fecha_hasta,
		   _fecha_suspension
		   with resume;	 
	
end foreach

end
drop table if exists tmp_avicanpoliza;
end procedure 
                                                                                                                                            
