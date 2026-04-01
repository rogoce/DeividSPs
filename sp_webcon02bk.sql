-- Listado de pólizas Acreedores
-- Creado    : 07/08/2019 - Autor: Federico Coronado

DROP PROCEDURE sp_webcon02bk;

CREATE PROCEDURE sp_webcon02bk(a_sql_describe lvarchar, a_busqueda smallint) 
  RETURNING char(50) 	as nombre,
char(15) 				as no_documento,
char(200) 				as no_unidad,
char(15) 				as nombre_ramo,
date 					as vigencia_inicial,
date 					as vigencia_final,
char(15)				as estado,
char(30)				as nombre_no_renov,
char(3)					as cod_endoremov,
char(10)				as no_poliza_vigente,
char(3)					as cod_ramo,
DEC(16,2)				as saldo,
DEC(16,2)				as saldo_venc,
DATE					as fecha_suspencion,  
DATE					as fecha_cancelacion,
DEC(16,2)				as exigible, 
DEC(16,2)				as corriente,
DEC(16,2)				as a30dias,
DEC(16,2)			    as a60_dias,
DEC(16,2)    		    as a90_dias,
smallint				as pintar,
varchar(30)				as cedula;
			
			
define _no_documento 		char(15);
define _no_poliza 			char(10);
define _no_poliza_vigente	char(10);
define _cod_contratante 	char(10);
define _cedula 				char(30);

define _vigencia_inic 		date;
define _vigencia_final 		date;
define _saldo 				decimal(10,2);
define _cod_ramo 			char(3);
define _cod_subramo 		char(3);
define _estatus_poliza 		integer;
define _estado 				char(15);
define _cod_no_renov 		char(3);
define _no_unidad 			char(5);

define _nombre 				char(60);
define _nombre_ramo 		char(30);
define _nombre_subramo 		char(20);
define _nombre_eminoren 	char(30);
define _periodo_hoy         varchar(7);
define _fecha               date;
define _fecha_aviso_canc    date;
define _fecha_suspension    date;
define _pintar              smallint;
DEFINE _cod_sucursal		varchar(3);
DEFINE _saldo_pend			decimal(16,2);
DEFINE _saldo_corr			decimal(16,2);
DEFINE _saldo_30dias		decimal(16,2);
DEFINE _saldo_60dias		decimal(16,2);
DEFINE _saldo_90dias		decimal(16,2);
DEFINE _saldo_venc			decimal(16,2);
define _no_unidad_concat    varchar(200);
define _count_uni			integer; 

--SET DEBUG FILE TO "sp_webcon01.trc";
--TRACE ON;
/*create temp table tmp_polizas(
		no_documento     char(20),
		no_unidad char(5)) with no log;*/
-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;
let _fecha = today; 
call sp_sis39(_fecha) RETURNING _periodo_hoy;
prepare equisql from a_sql_describe;	
declare equicur cursor for equisql;
open equicur;
	while (1 = 1)
		fetch equicur into	 --_cod_contratante,
							 _no_documento;
						    -- _no_unidad,
					       --  _cod_ramo,
					        -- _vigencia_inic,
					        -- _vigencia_final,
					       --  _cod_no_renov,
					        -- _no_poliza;	
		IF (SQLCODE = 100) THEN
			EXIT;
		END IF
--	insert into tmp_polizas(no_documento,no_unidad)values(_no_documento,_no_unidad);
	
let _no_unidad_concat = "";
let _count_uni = 1;
/*	
	foreach 
		select no_documento
		  into _no_documento
		  from tmp_polizas
	  group by 1
	  order by 1
*/		
		call sp_sis21(_no_documento) returning _no_poliza_vigente;
		let _estatus_poliza = 0;
		select estatus_poliza,
			   cod_sucursal,
			   fecha_aviso_canc,
			   cod_contratante,
			   cod_ramo,
			   vigencia_inic,
			   vigencia_final,
			   cod_no_renov
		  into _estatus_poliza,
			   _cod_sucursal,
			   _fecha_aviso_canc,
			   _cod_contratante,
			   _cod_ramo,
			   _vigencia_inic,
			   _vigencia_final,
			   _cod_no_renov
		  from emipomae
		 where no_poliza = _no_poliza_vigente;
		
		if a_busqueda = 1 then
			 foreach
				select a.no_unidad
				  into _no_unidad
				  from emipouni a inner join emipoacr b on a.no_poliza = b.no_poliza
				 where a.no_poliza = _no_poliza_vigente
				   and a.no_unidad = b.no_unidad 
				if _no_unidad_concat = '' then
					let _no_unidad_concat = _no_unidad;
				else
					let _no_unidad_concat = _no_unidad_concat || "|" ||_no_unidad;
				end if
				let _count_uni = 0;
			 end foreach

			if _count_uni = 1 then
				foreach
						SELECT z.no_poliza
						  into _no_poliza_vigente
						  FROM emipoacr b INNER JOIN emipouni p on b.no_poliza = p.no_poliza
					INNER JOIN emipomae z on z.no_poliza = p.no_poliza
						 where  b.no_unidad = p.no_unidad
						   AND z.actualizado = 1
						   and no_documento = _no_documento
					  order by z.vigencia_final desc
					exit foreach;
				end foreach
				select estatus_poliza,
					   cod_sucursal,
					   fecha_aviso_canc,
					   cod_contratante,
					   cod_ramo,
					   vigencia_inic,
					   vigencia_final,
					   cod_no_renov
				  into _estatus_poliza,
					   _cod_sucursal,
					   _fecha_aviso_canc,
					   _cod_contratante,
					   _cod_ramo,
					   _vigencia_inic,
					   _vigencia_final,
					   _cod_no_renov
				  from emipomae
				 where no_poliza = _no_poliza_vigente;
				foreach 
					select a.no_unidad
					  into _no_unidad
					  from emipouni a inner join emipoacr b on a.no_poliza = b.no_poliza
					 where a.no_poliza = _no_poliza_vigente
					   and a.no_unidad = b.no_unidad 
					if _no_unidad_concat = '' then
						let _no_unidad_concat = _no_unidad;
					else
						let _no_unidad_concat = _no_unidad_concat || "|" ||_no_unidad;
					end if
				end foreach
				--continue;
			end if
		else
			foreach
				select a.no_unidad
				  into _no_unidad
				  from emipouni a
				 where a.no_poliza = _no_poliza_vigente
				 
				if _no_unidad_concat = '' then
					let _no_unidad_concat = _no_unidad;
				else
					let _no_unidad_concat = _no_unidad_concat || "|" ||_no_unidad;
				end if
			 end foreach
		end if

		if _estatus_poliza = 1 then
			let _estado = "VIGENTE";
		elif _estatus_poliza = 2 then
			let _estado = "CANCELADA";
		elif _estatus_poliza = 3 then
			let _estado = "VENCIDA";
		else
			let _estado = "ANULADA";
		end if 	
		
			select cedula, 
				   nombre
			into _cedula,
				 _nombre
			from cliclien
			where cod_cliente = _cod_contratante;
			
			select nombre
			into _nombre_ramo				
			from prdramo 
			where cod_ramo = _cod_ramo;
			
			let _nombre_eminoren = '';
			--let _saldo = sp_cob115b('001', '001', _no_documento, '');
			
			if _cod_no_renov <> '' then
				select nombre
				  into _nombre_eminoren				
				  from eminoren 
				 where cod_no_renov = _cod_no_renov;
			end if
			
			SELECT fecha_suspension
			  into _fecha_suspension
			  FROM emipoliza 
			 WHERE no_documento = _no_documento;
			 
			let _pintar = 0;
			
			if _cod_contratante not in('394603','252627','621935') then
				if _fecha_suspension is null or _fecha_suspension = '' Then
				   let _fecha_suspension = null;
				else
					if date(_fecha) > date(_fecha_suspension) then
						let _pintar = 1;
					else
						let _fecha_suspension = null;
					end if
				end if
			else
					let _fecha_suspension = null;
			end if
			
			-- Morosidad de la Poliza
			call deivid:sp_cob33(
				'001',
				_cod_sucursal,
				_no_documento,
				_periodo_hoy,
				_fecha
				) RETURNING _saldo_venc,
							_saldo_pend,
							_saldo_corr,
							_saldo_30dias,
							_saldo_60dias,
							_saldo_90dias,
							_saldo; 
							
							
				   return _nombre,
						  _no_documento,
						  _no_unidad_concat,
						  _nombre_ramo,
						  _vigencia_inic,
						  _vigencia_final,
						  _estado,
						  _nombre_eminoren,
						  _cod_no_renov,
						  _no_poliza_vigente,
						  _cod_ramo,
						  _saldo,
						  _saldo_venc,
						  _fecha_suspension,
						  _fecha_aviso_canc,
						  _saldo_pend,
						  _saldo_corr,
						  _saldo_30dias,
						  _saldo_60dias,
						  _saldo_90dias,
						  _pintar,
						  _cedula
						  WITH RESUME;
			end while
	close equicur;	
	free equicur;
	free equisql;				  
	--END FOREACH
---drop table tmp_polizas;
END PROCEDURE;