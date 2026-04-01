--**********************************************************************************************************************************************************
-- Procedimiento para determinar la prima suscrita nueva de los corredores del bopno de producción de Ramos Generales.
--***********************************************************************************************************************************************************

-- Creado    : 12/10/2015 - Autor: Armando Moreno M.

DROP PROCEDURE sp_bono07;
CREATE PROCEDURE sp_bono07(a_cod_agente char(10))
RETURNING INTEGER;

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10);
define _cod_origen      char(3); 
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _nombre          CHAR(50); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE _no_licencia2    CHAR(10); 
DEFINE _nombre2         CHAR(50); 
define _forma_pag		smallint;
define _fecha_desde     date;
define _fecha_hasta     date;
define v_corr			DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
DEFINE _periodo_ant     CHAR(7);
define _mes_ant			smallint;
define _ano_ant			smallint;
define _prima_neta		DEC(16,2);
define _vigencia_inic   date;
define _vigencia_final  date;
define _fecha_cancelacion date;
define _renglon         smallint;
define _nueva_renov     char(1);
define _flag            smallint;
define _saldo           dec(16,2);
define _per_cero        char(7);
define _no_remesa       char(10);
define _no_recibo       char(10);
define _cnt             smallint;
define _prima_r         DEC(16,2);
define _monto_b         DEC(16,2);
define _prima_n         DEC(16,2);
define _cod_subramo     char(3);
define _concurso        smallint;
define _declarativa     smallint;
define _agente_agrupado char(5);
define _no_documento    char(20);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define v_por_vencer     DEC(16,2);
define v_exigible       DEC(16,2);
define v_corriente		DEC(16,2);
define v_monto_30		DEC(16,2);
define v_monto_60		DEC(16,2);
define v_saldo          DEC(16,2);
define _es_mensual      smallint ;
define _desde			char(7);
define _hasta           char(7);
define _fecha_ini		date;
define _fecha_fin		date;
define _fecha_anulado   date;
define _pagado          smallint;
define _monto_dev       dec(16,2);
define _no_requis		char(10);
define _monto_fac_ac    dec(16,2);
define _monto_fac       dec(16,2);
define _porc_partic_prima dec(16,2);
define _porc_proporcion   dec(16,2);
define _fronting		  smallint;
define _periodo           char(7);
define _porc_coaseguro    decimal(7,4);
define _cod_coasegur      char(3);
define _estatus_poliza    smallint;
define _prima             decimal(16,2);
define _cnt_uni           smallint;

--return 0; --se detuvo la corrida 01/10/2015 Armando

on exception set _error, _error_isam, _error_desc
   return _error;
end exception


--SET DEBUG FILE TO "sp_bono01.trc";
--TRACE ON;

let _error           = 0;
let _porc_coas_ancon = 0;
let _prima_neta      = 0;
let _cnt             = 0;
let _prima_r         = 0;
let _monto_b         = 0;
let _prima_n         = 0;
let _declarativa     = 0;
let v_por_vencer	 = 0;
let	v_exigible  	 = 0;
let	v_corriente		 = 0;
let	v_monto_30		 = 0;
let	v_monto_60		 = 0;
let	v_saldo     	 = 0;
let _monto_dev 		 = 0;
let _monto_fac_ac    = 0;
let _monto_fac		 = 0;
let _porc_proporcion = 0;
let _porc_partic_prima = 0;
let _prima_suscrita    = 0;
let _cnt_uni           = 0;

let _desde = null;
let _hasta = null;

SET ISOLATION TO DIRTY READ;

let _cod_coasegur = '036';	--ASEGURADORA ANCON, S.A.

--Buscar los corredores unificados
foreach
	select cod_agente
	  into _cod_agente
	  from unificar_rg
	 where cod_unificar = a_cod_agente
	 order by cod_agente

	foreach
		
			 select e.no_documento
			   into _no_documento
			   from emipomae e, emipoagt t
			  where e.no_poliza         = t.no_poliza
				and e.cod_compania      = '001'
				and e.actualizado       = 1
				and e.nueva_renov       = "N"
				and e.fecha_suscripcion >= "01/01/2017"  
				and e.fecha_suscripcion <= "31/12/2017"	
				and t.cod_agente        = _cod_agente
			   group by e.no_documento
			   order by e.no_documento

			  let _no_poliza = sp_sis21(_no_documento);
			  
			  select porc_partic_agt
				into _porc_partic
				from emipoagt
			   where cod_agente = _cod_agente
				 and no_poliza  = _no_poliza;
							 
			  select cod_ramo,
					 cod_subramo,
					 fronting,
					 cod_tipoprod,
					 prima_suscrita,
					 periodo,
					 estatus_poliza
				into _cod_ramo,
					 _cod_subramo,
					 _fronting,
					 _cod_tipoprod,
					 _prima_suscrita,
					 _periodo,
					 _estatus_poliza
				from emipomae
			   where no_poliza = _no_poliza;
			   
			if _estatus_poliza = 2 then			--Excluir póliza cancelada
				continue foreach;
			end if	
			if _cod_tipoprod in('002','004') then	--Se excluye tipo producción reaseguro asumido y coaseguro minoritario
				continue foreach;
			end if	

			if _fronting = 0 then				--Excluye Fronting
			else
				continue foreach;
			end if
			
			select count(*)
			  into _cnt
			  from emifafac
			 where no_poliza = _no_poliza;

			if _cnt > 0 then					--Excluye Facultativos
				select sum(a.prima)
				  into _prima_suscrita
				  from emifacon a, endedmae e, reacomae r
				 where a.no_poliza = e.no_poliza
				   and a.no_endoso = e.no_endoso
				   and a.cod_contrato = r.cod_contrato
				   and r.tipo_contrato not in(3)
				   and e.actualizado  = 1
				   and e.periodo      >= '2017-01'
				   and e.periodo  	  <= '2017-12'
				   and e.no_documento = _no_documento;
			end if
			--Solo permite los ramos de:  Responsabilidad Civil, Rotura de Maquinaria, Equipo Pesado, Robo, Equipo Electronico, Riesgos Varios, Car, Montaje.
			
			if _cod_ramo in('006','011','022','005','010','015','014','013') then
			elif _cod_ramo = '009' and _cod_subramo in('001','002','004') then	--Si es Transporte, solo perimite terrestre y maritimo.
			else
				continue foreach;
			end if
			   
			--Se Excluye poliza cancelada o rehabilitada en el periodo del concurso
			select count(*)
			  into _cnt
			  from endedmae
			 where no_poliza     = _no_poliza
			   and actualizado   = 1
			   and cod_endomov in ('003','002')  	
			   and fecha_emision >= '01/01/2017'
			   and fecha_emision <= '31/12/2017';
			   
			if _cnt > 0 then
				continue foreach;
			end if
			
			let _prima_suscrita = _prima_suscrita * (_porc_partic / 100);	--La prima suscrira por el % de participacion del corredor.
			
			{if _cod_tipoprod = "001" then	--Coaseguro Mayoritario, Nuestra participacion.

				select porc_partic_coas
				  into _porc_coaseguro
				  from emicoama
				 where no_poliza    = _no_poliza
				   and cod_coasegur = _cod_coasegur;

				if _porc_coaseguro is null then
					let _porc_coaseguro = 0.00;		          
				end if

				let _prima_suscrita = _prima_suscrita * (_porc_coaseguro / 100);
			end if}
			
			INSERT INTO bono_prod_d(
				cod_agente,
				prima_suscrita,
				periodo,
				no_documento,
				prima_cobrada,
				no_poliza,
				cod_agente_uni
				)
				VALUES(
				_cod_agente,
				_prima_suscrita,
				_periodo,
				_no_documento,
				0,
				_no_poliza,
				a_cod_agente
				);
	end foreach
	
end foreach

return 0;

END PROCEDURE;