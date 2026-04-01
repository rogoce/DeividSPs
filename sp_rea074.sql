-- Procedimiento que trae la distribucion de no_unidad.
-- Creado    : 29/08/2017 -- Henry Giron
-- Execute procedure sp_rea074('21/07/2017')

DROP PROCEDURE sp_rea074;
CREATE PROCEDURE sp_rea074(a_fecha date)
RETURNING char(5),
char(20),
dec(16,2),
dec(16,2),
dec(16,2),
dec(16,2),
dec(9,2),
dec(9,2),
char(50),
char(50),
char(5),
char(50),
char(3),
char(50),
smallint,
smallint,
char(15),
dec(16,2),
dec(16,2),
smallint,
char(50);

DEFINE _no_poliza       CHAR(10);
define _cod_subramo     char(3); 
define _cod_origen      char(3); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _renglon         SMALLINT; 
DEFINE _monto           DEC(16,2);
DEFINE _no_recibo       CHAR(10); 
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50);
DEFINE _no_requis       CHAR(10); 
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
define _fecha_hoy       date;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define _prima_45        DEC(16,2);
define _prima_90		DEC(16,2);
define _prima_r  		DEC(16,2);
define _prima_rr  		DEC(16,2);
define _formula_a  		DEC(16,2);
define _cnt             integer;
define v_monto_30bk		DEC(16,2);
define v_corr			DEC(16,2);
DEFINE _formula_b       DEC(16,2);
define _comision1       DEC(16,2);
define _comision2       DEC(16,2);
define _prima_bruta     DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);				   
define _cedula_paga		char(30);				   
define _cedula_cont		char(30);				   
define _cod_pagador     char(10);				   
define _cod_contratante char(10);				   
define _estatus_licencia char(1);				   
define v_nombre_clte     char(100);				   
define _cod_contr        char(10);
define _error           smallint;				   
define _monto_m			DEC(16,2);				   
define _comision		DEC(16,2);				   
define _suc_origen      char(3);				   
define _beneficios      smallint;				   
define _contado         smallint;				   
define _dias            integer;
define _fecha_decla     date;
define _mess            integer;
define _anno            integer;
define _f_ult           date;
define _f_decla_ult     date;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _concurso        smallint;
define _no_cuenta       char(17);

define _suma_aseg_pol	dec(16,2);
define _prima_sus_pol	dec(16,2);
define _no_documento    char(20);
define _estatus         smallint;
define _no_unidad       char(5);
define _suma_asegurada  dec(16,2);
define _prima_suscrita	dec(16,2);
define _porc_partic_suma	decimal(9,6);
define _porc_partic_prima	decimal(9,6);
define _cod_contrato     char(5);
define _tipo_contrato,_orden   smallint;
define _n_tipoprod      char(50);
define _nombre_cliente	char(50);
define _cod_cobertura   char(3);
define _n_contrato       char(50);
define _n_cobertura      char(50);
define _n_tipo_contrato  char(15);
define _porc_prima		dec(16,2);
define _porc_suma       dec(16,2);
define _periodo				char(7);
define _fecha_cancelacion	date;
define _fecha_emision		date;
define _no_cambio			smallint;
define _no_endoso			char(5);
define _tipo_incendio       smallint;
define _n_tipo_incendio     char(50);

SET ISOLATION TO DIRTY READ;
drop table if exists tmp_ram0;
drop table if exists tmp_dist0;

create temp table tmp_ram0(
no_poliza	 char(10),
no_unidad    char(5),
no_documento char(20),
prima_unidad dec(16,2),
prima_sus    dec(16,2),
suma_unidad	 dec(16,2),
suma		 dec(16,2),
porc_prima	 dec(16,2),
porc_suma	 dec(16,2)
) with no log;

create temp table tmp_dist0
(no_poliza   	char(10),
no_unidad		char(5),
no_documento	char(20),
cod_contrato	char(5),
n_contrato		char(50),
cod_cobertura	char(3),
n_cobertura		char(50),
tipo_contrato	smallint,
n_tipo_contrato	char(15),
porc_prima		dec(16,2),
porc_suma 		dec(16,2),
tipo_incendio	smallint,
n_tipo_incendio	char(50),
orden           smallint) 
with no log;

let _periodo = sp_sis39(a_fecha);
--set debug file to "sp_rea074.trc";
--trace on;
foreach
	select d.no_poliza,
		   e.no_endoso,
		   d.no_documento,
		   d.fecha_cancelacion
	  into _no_poliza,
		   _no_endoso,
		   _no_documento,
		   _fecha_cancelacion
	  from emipomae d, endedmae e
	 where e.no_poliza = d.no_poliza
	   and d.cod_compania = '001'
	   and d.cod_ramo in ('001','003')
	   and (d.vigencia_final >= a_fecha or d.vigencia_final is null)
	   and d.fecha_suscripcion <= a_fecha
	   and e.fecha_emision <= a_fecha
	   and d.vigencia_inic < a_fecha
	   and e.periodo <= _periodo
	   and d.actualizado = 1
	   and e.actualizado = 1
	   --and d.no_poliza = '1020175'

	let _fecha_emision = null;

	if _fecha_cancelacion <= a_fecha then
		foreach
			select fecha_emision
			  into _fecha_emision
			  from endedmae
			 where no_poliza = _no_poliza
			   and cod_endomov = '002'
			   and vigencia_inic = _fecha_cancelacion
		end foreach

		if  _fecha_emision <= a_fecha then
			continue foreach;
		end if
	end if
	
    --let _no_poliza = sp_sis21(_no_documento);	
	select suma_asegurada,
		   prima_suscrita
	  into _suma_aseg_pol,
	       _prima_sus_pol
	  from emipomae
	 where no_poliza = _no_poliza; 

		foreach
			select no_unidad,
			       suma_asegurada,
				   prima_suscrita
			  into _no_unidad,
			       _suma_asegurada,
				   _prima_suscrita
			  FROM endeduni 
			 WHERE no_poliza = _no_poliza
			   and no_endoso = _no_endoso	

			insert into tmp_ram0
			values (_no_poliza, _no_unidad,_no_documento, _prima_suscrita,_prima_sus_pol,_suma_asegurada, _suma_aseg_pol, 0.00, 0.00);
			
				LET _tipo_incendio = 0;						
		    
				FOREACH
					SELECT tipo_incendio
					  INTO _tipo_incendio
					  FROM emipouni
					 WHERE no_poliza = _no_poliza
					   and no_unidad = _no_unidad
					exit foreach;
				end foreach	  

				if _tipo_incendio = 0 or  _tipo_incendio is null then
					
					FOREACH
						SELECT tipo_incendio
						  INTO _tipo_incendio
						  FROM endeduni
						 WHERE no_poliza = _no_poliza
						   AND no_endoso = _no_endoso
						   and no_unidad = _no_unidad
						exit foreach;
					end foreach	  			
					
					if  _tipo_incendio is null then
						let _tipo_incendio = 0;
					end if
				end if	
				
				if  _tipo_incendio = 1 then 
					let _n_tipo_incendio = "EDIFICIO";
				elif _tipo_incendio = 2 then 
					let _n_tipo_incendio = "CONTENIDO";
				elif _tipo_incendio = 3 then 
					let _n_tipo_incendio = "LUCRO CESANTE";
				elif _tipo_incendio = 4 then 
					let _n_tipo_incendio = "PERDIDA DE RENTA";				
				else
					let _n_tipo_incendio = "SIN ASIGNAR";
				end if						
			
				foreach
				select no_cambio
				  into _no_cambio
				  from emireama
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and vigencia_inic   <= a_fecha
				   and (vigencia_final >= a_fecha or vigencia_final is null)
				 order by no_cambio desc
				exit foreach;
			end foreach
			

			 foreach
				select distinct y.cod_contrato, 
				       x.cod_cober_reas, 
					   x.porc_partic_suma, 
					   x.porc_partic_prima,  
					   t.es_terremoto
				  into _cod_contrato,
					   _cod_cobertura,
					   _porc_partic_suma,
					   _porc_partic_prima,
					   _orden
				   From emipocob e, prdcober c, reacobre t, emireaco x, reacomae y
				  Where e.no_poliza = _no_poliza
				    And e.no_unidad = _no_unidad
					And e.cod_cobertura = c.cod_cobertura
					And c.cod_cober_reas = t.cod_cober_reas
					and x.no_poliza = e.no_poliza
				   and x.no_unidad = e.no_unidad
				   and x.no_cambio = _no_cambio
				   and y.cod_contrato = x.cod_contrato
				   and c.cod_cober_reas = x.cod_cober_reas   


				select tipo_contrato,nombre
				  into _tipo_contrato,_n_contrato
				  from reacomae
				 where cod_contrato = _cod_contrato;

		         select nombre
		           into _n_cobertura
		           from reacobre
		          where cod_cober_reas = _cod_cobertura;

				let _porc_prima = _porc_partic_prima;
				let	_porc_suma	= _porc_partic_suma;

				if  _tipo_contrato = 1 then 
					let _n_tipo_contrato = "Retencion";
				elif _tipo_contrato = 2 then 
					let _n_tipo_contrato = "Facultativo";
				elif _tipo_contrato = 3 then 
					let _n_tipo_contrato = "Facultativo";
				elif _tipo_contrato = 4 then 
					let _n_tipo_contrato = "Normal";
				elif _tipo_contrato = 5 then 
					let _n_tipo_contrato = "Cuota Parte";
				elif _tipo_contrato = 6 then 
					let _n_tipo_contrato = "Exceso de Perdida";
				elif _tipo_contrato = 7 then 
					let _n_tipo_contrato = "Excedente";
				end if

				insert into tmp_dist0 (no_poliza,no_unidad,no_documento,cod_contrato,n_contrato,cod_cobertura,n_cobertura,tipo_contrato,n_tipo_contrato,porc_prima,porc_suma,orden,tipo_incendio,n_tipo_incendio)
				values (_no_poliza,_no_unidad,_no_documento,_cod_contrato,_n_contrato,_cod_cobertura,_n_cobertura,_tipo_contrato,_n_tipo_contrato,_porc_prima,_porc_suma,_orden,_tipo_incendio,_n_tipo_incendio)	;


			 end foreach

		end foreach

end foreach
--trace off;
foreach
	select no_unidad,
		   no_documento,
		   prima_unidad,
		   prima_sus,
		   suma_unidad,
		   suma,
		   porc_prima,
		   porc_suma,
		   no_poliza
	  into _no_unidad,
		   _no_documento,
		   _prima_suscrita,
		   _prima_sus_pol,
		   _suma_asegurada,
		   _suma_aseg_pol,
		   _porc_partic_suma,
		   _porc_partic_prima,
		   _no_poliza
	  from tmp_ram0

	--let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod,
	       cod_contratante
	  into _cod_tipoprod,
	       _cod_contratante
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre
	  into _n_tipoprod
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	 foreach
	select cod_contrato,
			n_contrato,
			cod_cobertura,
			n_cobertura,
			orden,
			tipo_contrato,
			n_tipo_contrato,
			porc_prima,
			porc_suma,
			tipo_incendio,
			n_tipo_incendio
		  into _cod_contrato,
			_n_contrato,
			_cod_cobertura,
			_n_cobertura,
			_orden,
			_tipo_contrato,
			_n_tipo_contrato,
			_porc_prima,
			_porc_suma,
			_tipo_incendio,
			_n_tipo_incendio
	  from tmp_dist0
	  where no_unidad = _no_unidad
	    and no_documento  = _no_documento
	    and no_poliza = _no_poliza
		order by 1,3,5

			return _no_unidad,
			       _no_documento,
				   _prima_suscrita,
				   _prima_sus_pol,
				   _suma_asegurada,
				   _suma_aseg_pol,
				   _porc_partic_suma,
				   _porc_partic_prima,
				   _n_tipoprod,
				   _nombre_cliente,
				   _cod_contrato,
				   _n_contrato,
				   _cod_cobertura,
				   _n_cobertura,
				   _orden,
				   _tipo_contrato,
				   _n_tipo_contrato,
				   _porc_prima,
				   _porc_suma,
				   _tipo_incendio,
			       _n_tipo_incendio
				   with resume;

	  end foreach

end foreach

--drop table tmp_ram0;
--drop table tmp_dist0;


END PROCEDURE;