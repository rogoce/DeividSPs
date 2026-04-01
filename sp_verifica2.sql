
DROP PROCEDURE sp_verifica2;

CREATE PROCEDURE sp_verifica2()
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
dec(16,2);

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

SET ISOLATION TO DIRTY READ;

create temp table tmp_ramo(
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

create temp table tmp_dist
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
orden           smallint) with no log;

foreach

	select no_documento
	  into _no_documento
	  from emipomae
	 where actualizado    = 1
	   and suma_asegurada >= 16000000
	   and cod_ramo       = '001'
	   and estatus_poliza = 1
--	   and no_documento   = '0109-00700-01'
     group by no_documento
     order by no_documento

	let _no_poliza = sp_sis21(_no_documento);

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
			  from emipouni
			 where no_poliza = _no_poliza

			insert into tmp_ramo
			values (_no_poliza, _no_unidad,_no_documento, _prima_suscrita,_prima_sus_pol,_suma_asegurada, _suma_aseg_pol, 0.00, 0.00);

			 foreach
				select cod_contrato,
				       cod_cober_reas,
					   porc_partic_suma,
					   porc_partic_prima,
					   orden
				  into _cod_contrato,
				       _cod_cobertura,
					   _porc_partic_suma,
					   _porc_partic_prima,
					   _orden
				  from emifacon
				 where no_poliza = _no_poliza
				   and no_endoso = "00000"
				   and no_unidad = _no_unidad

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

				insert into tmp_dist (no_poliza,no_unidad,no_documento,cod_contrato,n_contrato,cod_cobertura,n_cobertura,tipo_contrato,n_tipo_contrato,porc_prima,porc_suma,orden)
				values (_no_poliza,_no_unidad,_no_documento,_cod_contrato,_n_contrato,_cod_cobertura,_n_cobertura,_tipo_contrato,_n_tipo_contrato,_porc_prima,_porc_suma,_orden)	;

				{if _tipo_contrato = 1 then --retencion
					 update tmp_ramo
					    set porc_prima = _porc_partic_prima,
							porc_suma  = _porc_partic_suma
					  where no_poliza  = _no_poliza
					    and no_unidad  = _no_unidad;			
					 exit foreach;
				else
				   let _porc_partic_prima = 0.00;
				   let _porc_partic_suma  = 0.00;
				end if}

			 end foreach

		end foreach

end foreach

foreach
	select no_unidad,
		   no_documento,
		   prima_unidad,
		   prima_sus,
		   suma_unidad,
		   suma,
		   porc_prima,
		   porc_suma
	  into _no_unidad,
		   _no_documento,
		   _prima_suscrita,
		   _prima_sus_pol,
		   _suma_asegurada,
		   _suma_aseg_pol,
		   _porc_partic_suma,
		   _porc_partic_prima
	  from tmp_ramo

	let _no_poliza = sp_sis21(_no_documento);

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
			porc_suma
		  into _cod_contrato,
			_n_contrato,
			_cod_cobertura,
			_n_cobertura,
			_orden,
			_tipo_contrato,
			_n_tipo_contrato,
			_porc_prima,
			_porc_suma
	  from tmp_dist
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
				   _porc_suma
				   with resume;

	  end foreach

end foreach

drop table tmp_ramo;
drop table tmp_dist;


END PROCEDURE;