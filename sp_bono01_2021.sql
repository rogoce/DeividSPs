--**********************************************************************************************************************************************************
-- Procedimiento para determinar la prima suscrita nueva de los corredores del bono de producción de Ramos Generales 2021
--***********************************************************************************************************************************************************

-- Creado    : 12/10/2015 - Autor: Armando Moreno M.

DROP PROCEDURE sp_bono01;
CREATE PROCEDURE sp_bono01()
RETURNING INTEGER;

DEFINE _cod_agente      CHAR(5);
DEFINE _cod_agente_tmp  CHAR(5);
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
define _prima_retenida    decimal(16,2);
define _cnt_rg			  smallint;
define _valor             smallint;
define _ano_actual,_unificar        integer;
define _periodo_actual    char(7);

on exception set _error, _error_isam, _error_desc
   return _error;
end exception

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
let _cnt_rg            = 0;
let _prima_retenida    = 0;

let _desde = null;
let _hasta = null;

SET ISOLATION TO DIRTY READ;

--******************************************************
select periodo_verifica
  into _periodo_actual
  from emirepar;

--PONER EN COMENTARIO AL INICIAR.
if _periodo_actual[1,4] = '2022' then
	--return 0; --se detiene la corrida, en el cierre contable de diciembre, Armando.
end if
--******************************************************
let _cod_coasegur = '036';	--ASEGURADORA ANCON, S.A.

delete from bono_prod_d;

--let _ano_actual = year(current);
--let _periodo_actual = _ano_actual || '-12';

--SET DEBUG FILE TO "sp_bono01.trc";
--TRACE ON;

foreach
	select cod_agente
	  into _cod_agente
	  from agtagent
	 where tipo_agente = 'A'
	    or cod_agente in('02531','02532','02618') --Condicion especial para estos codigos que son directos, pero su produccion mas abajo se unifica.11/02/2019
	 order by cod_agente
	 
	if _cod_agente = '02111' then	--Se excluye cualquier poliza de este codigo de Javier Avila que es solo para talleres.
		continue foreach;
	end if
	foreach
			 select e.no_documento,e.no_poliza
			   into _no_documento,_no_poliza
			   from emipomae e, emipoagt t
			  where e.no_poliza         = t.no_poliza
				and e.cod_compania      = '001'
				and e.actualizado       = 1
				and e.nueva_renov       = "N"
				and e.periodo >= "2021-01"
				and e.periodo <= "2021-12"	
				and t.cod_agente        = _cod_agente
			   group by e.no_documento,e.no_poliza
			   order by e.no_documento

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
					 estatus_poliza,
					 prima_retenida,
					 fecha_cancelacion,
					 cod_grupo
				into _cod_ramo,
					 _cod_subramo,
					 _fronting,
					 _cod_tipoprod,
					 _prima_suscrita,
					 _periodo,
					 _estatus_poliza,
					 _prima_retenida,
					 _fecha_cancelacion,
					 _cod_grupo
				from emipomae
			   where no_poliza = _no_poliza;
			   
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

			if _cnt > 0 then					--Excluye prima de contratos Facultativos
				select sum(a.prima)
				  into _prima_suscrita
				  from emifacon a, endedmae e, reacomae r
				 where a.no_poliza = e.no_poliza
				   and a.no_endoso = e.no_endoso
				   and a.cod_contrato = r.cod_contrato
				   and r.tipo_contrato not in(3)
				   and e.actualizado  = 1
				   and e.periodo      >= '2021-01'
				   and e.periodo  	  <= '2021-12'
				   and e.no_documento = _no_documento;

				if _prima_suscrita is null then	--Significa que toda la prima es facultativa, por ende no se toma en cuenta la poliza.
					let _prima_suscrita = 0.00;
					continue foreach;
				end if
			end if
			--Solo permite los ramos de:  Responsabilidad Civil, Rotura de Maquinaria, Equipo Pesado, Robo, Equipo Electronico, Riesgos Varios, Car, Montaje.
			
			if _cod_ramo in('006','011','022','005','010','015','014','013') then
			elif _cod_ramo = '009' and _cod_subramo in('001','002','004','003','006') then	--Si es Transporte, perimite terrestre y maritimo y Aereo.
			else
				continue foreach;
			end if
			--**Para riesgos catastróficos se debe quitar 30% al ramo de CAR, correo Analisa 01/02/2018
			if _cod_ramo in('014') then --Ramo CAR, se multiplica la prima suscrita por 70%
				let _prima_suscrita = _prima_suscrita * 70 /100;
			end if	
			--***********************************************
			--Se Excluye poliza cancelada o rehabilitada, o traspaso de cartera o cambio de corredor en el periodo del concurso
			select count(*)
			  into _cnt
			  from endedmae
			 where no_poliza     = _no_poliza
			   and actualizado   = 1
			   and cod_endomov in ('003','002','012','031')  	
			   and fecha_emision >= '01/01/2021'
			   and fecha_emision <= '31/12/2021';
			   
			if _cnt > 0 then
				continue foreach;
			end if
			if _prima_suscrita is null then
				let _prima_suscrita = 0.00;
			end if	
			let _prima_suscrita = _prima_suscrita * (_porc_partic / 100);	--La prima suscrira por el % de participacion del corredor.
			
			if _cod_tipoprod = "001" then	--Coaseguro Mayoritario, Nuestra participacion.
				if _cod_grupo in('00000','1000') then --Grupo del estado no aplica
					continue foreach;
				end if
			end if
			
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
				_cod_agente
				);
	end foreach
end foreach
foreach

	select no_poliza,
	       cod_agente
	  into _no_poliza,
           _cod_agente	  
	  from bono_prod_d
	 order by cod_agente

	foreach
			select d.no_poliza,
				   d.no_remesa,
				   d.renglon,
				   d.no_recibo,
				   d.fecha,
				   d.monto,
				   d.prima_neta,
				   d.tipo_mov,
				   c.porc_partic_agt
			  into _no_poliza,
				   _no_remesa,
				   _renglon,
				   _no_recibo,
				   _fecha,
				   _monto,
				   _prima,
				   _tipo_mov,
				   _porc_partic
			  from cobredet d, cobremae m, cobreagt c
			 where	d.no_remesa    = m.no_remesa
			   and d.no_remesa    = c.no_remesa
			   and d.renglon      = c.renglon
			   and d.cod_compania = '001'
			   and d.actualizado  = 1
			   and d.tipo_mov     in ('P','N')
			   and d.fecha        >= '01/01/2021'
			   and d.fecha        <= '31/12/2021'
			   and d.no_poliza     = _no_poliza
			   and m.tipo_remesa  in ('A', 'M', 'C')
			   and c.cod_agente   = _cod_agente
			 order by d.fecha,d.no_recibo,d.no_poliza
			 
			 select cod_tipoprod
		       into _cod_tipoprod
			   from emipomae
              where no_poliza = _no_poliza;

			if _cod_tipoprod = "001" then	-- Coaseguro Mayoritario, nuestra participacion.

				select porc_partic_coas
				  into _porc_coaseguro
				  from emicoama
				 where no_poliza    = _no_poliza
				   and cod_coasegur = _cod_coasegur;

				if _porc_coaseguro is null then
					let _porc_coaseguro = 0.00;		          
				end if
				
				let _prima = _prima * (_porc_coaseguro / 100);
			end if
			
			let _prima = _prima * (_porc_partic / 100);
			 
			update bono_prod_d
               set prima_cobrada = prima_cobrada + _prima
             where cod_agente = _cod_agente
               and no_poliza  = _no_poliza;			 

	end foreach
end foreach
--unificaciones
foreach
	select cod_agente
	  into _cod_agente	  
	  from bono_prod_d
	 group by cod_agente 
	 order by cod_agente
	 
	let _cod_agente_tmp = '';
	let _cod_agente_tmp = _cod_agente;

	--********  Unificacion de Agente *******
	call sp_che168(_cod_agente_tmp) returning _error,_cod_agente;	

	update bono_prod_d
	   set cod_agente     = _cod_agente,
		   cod_agente_uni = _cod_agente
     where cod_agente = _cod_agente_tmp;
			   
end foreach
return 0;
END PROCEDURE;