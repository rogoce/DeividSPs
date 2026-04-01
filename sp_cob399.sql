
-- Procedimiento que Genera la nulidad automática.
-- Creado    : 20/07/2017 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob399;
create procedure sp_cob399()
returning	integer			as cod_error,
			varchar(100)	as error_desc;

define _error_desc			varchar(100);
define _nom_contratante		varchar(50);
define _nom_formapag	    varchar(50);
define _nom_campana			varchar(50);
define _nom_agente			varchar(50);
define _cia_nombre          varchar(50); 
define _nom_grupo			varchar(50);
define _nom_ramo			varchar(50); 
define _desc_gestion	    varchar(30);
define _nom_gestion		    varchar(30);
define _nom_zona		    varchar(30);
define _desc_n_r            varchar(10);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _cod_campana			char(10);
define _no_poliza			char(10);
define _user_added			char(8);
define _cod_formapag        char(5);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _gestion_automatica	char(3); 
define _sus_gest_automatic	char(3); 
define _cod_cobrador		char(3); 
define _cod_gestion			char(3); 
define _cod_ramo            char(3); 
define _nueva_renov			char(1);
define _prima_bruta			dec(16,2);
define _dias_transcurridos	smallint;
define _cnt_susp_nulidad	smallint;
define _cliente_vip			smallint;
define _tipo_aviso			smallint;
define _cnt_anula			smallint;
define _excepcion			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_primer_pago	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_nulidad		date;
define _fecha_gestion		date;
define _fecha_actual		date;
define _fecha_hasta		    date;
define _fecha_hoy			date;
define _celular				char(10);
define _a_pagar             dec(16,2);
define _cod_producto        char(6);
define _n_producto          char(50);

--set debug file to 'sp_cob398.trc';
--trace on ;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error,_error_desc;--,current;
end exception

--return 0,'Actualización Exitosa';  Solicitud RGORDON 13/02/2023 

let _fecha_hoy = today;
let _cod_gestion = '073';
let _desc_gestion = 'PROCESO DE NULIDAD AUTOMATICA.';
let _tipo_aviso = 20; -- Gestión Automática

select valor_parametro
  into _sus_gest_automatic
  from inspaag
 where codigo_parametro = 'sus_gest_automatic';

select cod_gestion || ' - ' || trim(nombre)
  into _nom_gestion
  from cobcages
 where cod_gestion = _sus_gest_automatic;

select valor_parametro
  into _user_added
  from inspaag
 where codigo_parametro = 'user_automatico';

select valor_parametro
  into _cnt_susp_nulidad
  from inspaag
 where codigo_parametro = 'dias_susp_nulidad';

foreach
	execute procedure sp_cas115(1) 
	into _no_documento,
		 _cod_contratante,
		 _nom_contratante,
		 _fecha_primer_pago,
		 _vigencia_inic,
		 _vigencia_final,
		 _cod_formapag,
		 _nom_formapag,
		 _cod_grupo,
		 _nom_grupo,
		 _cod_agente,
		 _nom_agente,
		 _cod_cobrador,
		 _nom_zona,
		 _cod_ramo,
		 _nom_ramo,
		 _prima_bruta,
		 _desc_n_r,
		 _fecha_nulidad,
		 _cod_campana,
		 _nom_campana,
		 _dias_transcurridos,
		 _cia_nombre,
		 _cliente_vip,
		 _fecha_actual,
		 _fecha_hasta,
		 _celular,
		 _a_pagar,
		 _cod_producto,
		 _n_producto

	if _fecha_nulidad <= _fecha_hoy then

		select count(*)
		  into _cnt_anula
		  from cobanula
		 where no_documento = _no_documento;

		if _cnt_anula is null then
			let _cnt_anula = 0;
		end if

		if _cnt_anula <> 0 then
			continue foreach;
		end if

		let _excepcion = 0;

		foreach
			select cod_gestion,
				   max(date(fecha_gestion))
			  into _gestion_automatica,
				   _fecha_gestion
			  from cobgesti
			 where no_documento = _no_documento
			   and cod_gestion = _sus_gest_automatic
			 group by 1

			if _gestion_automatica is not null then
				let _fecha_nulidad = _fecha_gestion + _cnt_susp_nulidad units day;
				
				if _fecha_nulidad >= _fecha_hoy then
					let _excepcion = 1;
				end if
			end if
			exit foreach;
		end foreach

		if _excepcion = 1 then
			continue foreach;
		end if
		
		update cascliente
		   set cod_cobrador = null
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_contratante;

		let _no_poliza = sp_sis21(_no_documento);

		insert into cobanula(
				cod_campana,
				cod_cliente,
				cod_gestion,
				no_documento,
				date_added)
		values(	_cod_campana,
				_cod_contratante,
				_cod_gestion,
				_no_documento,
				current);

		insert into cobgesti(
				cod_gestion,
				fecha_gestion,
				cod_pagador,
				desc_gestion,
				no_documento,
				no_poliza,
				tipo_aviso,
				user_added)
		values(	_cod_gestion,
				current,
				_cod_contratante,
				_desc_gestion,
				_no_documento,
				_no_poliza,
				_tipo_aviso,
				_user_added);
	end if
end foreach

return 0,'Actualización Exitosa';

end
end procedure;