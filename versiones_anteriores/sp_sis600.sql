-- polizas vigentes Manzanas distribucion
-- Creado: 01/09/2020 - Autor: Henry Giron

drop procedure sp_sis600;
create procedure "informix".sp_sis600(a_cod_manzana char(255) default '*', a_poliza char(20) DEFAULT '*', a_estatus_poliza smallint default 1,a_no_unidad char(5),a_suma_asegurada dec(16,2) default 0)
returning smallint, varchar(250);

define _ret_porc		  dec(9,4);
define _fac_porc		  dec(9,4);
define _exc_porc		  dec(9,4);
define _porc_partic_suma  dec(9,4);
define _porc_coas         dec(7,4);

define _no_poliza		  char(10);
define _contratante	      char(10);
define _no_unidad		  char(5);
define _fecha       	  date;
define v_asegurado		  char(100);
define _no_documento      char(20);
define v_filtros          char(255);
define _cod_manzana		  char(15);
define _suc_origen		  char(3);
define _n_suc_origen	  char(30);
define _referencia        char(50);
define _suma_asegurada    dec(16,2);
define _suma			  dec(16,2);
define _suma_ret		  dec(16,2);
define _suma_fac		  dec(16,2);
define _suma_exc		  dec(16,2);
define _poliza		      char(10);

define _actualizado       smallint;
define _tipo_incendio     smallint;
define _vig_ini           date;
define _vig_fin           date;
define _cod_ramo         char(3);
define v_cod_contrato     char(5);
define v_tipo_contrato    smallint;
define _est_pol			  smallint;
define _nombre_ag		  char(255);
define _nombre_ag_acum	  char(255);
define _cod_cober_reas	  char(3);

define _no_cambio	      smallint;
define _fecha_cancelacion date;
define _fecha_emision     date;
define _cod_coasegur      char(3);

define _prima_suscrita    dec(16,2);
define _coaseguro         varchar(25);
define _cod_tipoprod      char(3);
define _cod_ramo_uni,_cod_subramo   char(3);
define _max_retencion     decimal(16,2);
define _max_suma_asegurada     decimal(16,2);

define _mensaje           varchar(250);
define _flag	      smallint;


drop table if exists temp_sis600;	
create temp table temp_sis600 (
	no_poliza	        char(10),
	no_unidad	        char(5),
	no_documento	    char(20),
	asegurado	        char(100),  
	cod_manzana	        char(15),
	referencia	        char(50),
	sucursal_origen	    char(3),
	nombre_suc_origen	char(30),   
	suma_asegurada	    decimal(16,2),
	tipo_incendio	    smallint,
	vig_ini	            date,
	vig_fin	            date,
	tot_retencion	    decimal(16,2),
	estauts_poliza	    smallint,
	agentes_poliza	    char(100),   
	tot_facultativo	    decimal(16,2),
	tot_excedente	    decimal(16,2),
	Porc_retencion	    decimal(9,4),
	Porc_excedente	    decimal(9,4),
	Porc_facultativo	decimal(9,4),
	Prima_Suscrita	    decimal(16,2),   
	coaseguro	        varchar(25)
) with no log;

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02('001','001');
--set debug file to "sp_sis600.trc";
--trace on;

let _fecha = CURRENT;
let _suma_asegurada = 0;
let _suma_ret       = 0;
let _nombre_ag_acum = '';
let _max_retencion = 500000.00;

 select trim(valor_parametro) ,aplicacion
  into _max_retencion
  from inspaag
 where codigo_compania	= '001'
   and codigo_agencia	= '001'
   and aplicacion	= 'PRO'
   and version		= '02'
   and codigo_parametro	= 'max_ret_manzana';
   
 select trim(valor_parametro) ,aplicacion
  into _max_suma_asegurada
  from inspaag
 where codigo_compania	= '001'
   and codigo_agencia	= '001'
   and aplicacion	= 'PRO'
   and version		= '02'
   and codigo_parametro	= 'max_suma_manzana'

drop table if exists tmp_cober_reas;
select cod_cober_reas
  from reacobre
 where cod_ramo in ('001','003')
   and es_terremoto = 0
  into temp tmp_cober_reas;
let _poliza = sp_sis21(a_poliza);

  FOREACH WITH HOLD

				select emipouni.no_unidad,
					   emipouni.no_poliza,
					   emipouni.suma_asegurada,
					   emipouni.prima_suscrita,
					   cod_asegurado,
					   tipo_incendio,
					   cod_manzana,
                       emipomae.fecha_cancelacion,
					   emipouni.cod_ramo
				 into  _no_unidad,
					   _no_poliza,
					   _suma_asegurada,
					   _prima_suscrita,
					   _contratante,
					   _tipo_incendio,
					   _cod_manzana,
					   _fecha_cancelacion,
					   _cod_ramo_uni
				 from emipouni,
					  emipomae
				where emipouni.cod_manzana LIKE TRIM(a_cod_manzana) || "%"
				  and emipouni.no_poliza = _poliza
				  and emipouni.no_poliza = emipomae.no_poliza
				  and (emipouni.cod_manzana <> '' and emipouni.cod_manzana is not null)
				  and emipomae.fecha_suscripcion <= _fecha
				  and emipomae.vigencia_inic <= _fecha
				  and emipomae.actualizado = 1
				  and emipomae.cod_ramo in ('001','003')
				order by emipouni.cod_manzana, emipouni.no_poliza, emipouni.no_unidad

				let _fecha_emision = null;


	   		SELECT nombre
	     	 INTO  v_asegurado
	     	 FROM  cliclien
	    	 WHERE cod_cliente = _contratante;

			SELECT sucursal_origen,
			       no_documento,
			  	   actualizado,
				   vigencia_inic,
				   vigencia_final,
				   cod_ramo,
				   estatus_poliza, 
				   cod_tipoprod,
				   cod_subramo
			  INTO _suc_origen,
			       _no_documento,
			  	   _actualizado,
				   _vig_ini,
				   _vig_fin,
				   _cod_ramo,
				   _est_pol,
				   _cod_tipoprod,
				   _cod_subramo
			  FROM emipomae
		     WHERE no_poliza      = _no_poliza;
			 
			if _cod_ramo = '003' and _cod_subramo = '006' then
				if _cod_ramo_uni = '001' then
				else
					continue foreach;
				end if
			end if
			
			-- Informacion de Coaseguro
			let _coaseguro = "";
			IF _cod_tipoprod = '001' THEN
			    let _coaseguro = "COASEGURO MAYORITARIO";
				SELECT porc_partic_coas
				  INTO _porc_coas
				  FROM emicoama
				 WHERE no_poliza    = _no_poliza
				   AND cod_coasegur = _cod_coasegur;

				IF _porc_coas IS NULL THEN
					LET _porc_coas = 0;
				END IF
				
				let _suma_asegurada = _suma_asegurada * _porc_coas / 100;
				let _prima_suscrita = _prima_suscrita * _porc_coas / 100;
			ELIF _cod_tipoprod = '002' THEN
			    let _coaseguro = "COASEGURO MINORITARIO";
            END IF

		    SELECT descripcion
		     INTO  _n_suc_origen
		     FROM  insagen
		     WHERE codigo_compania = "001"
		     AND   codigo_agencia  = _suc_origen;

	   		SELECT referencia
	     	  INTO _referencia
	          FROM emiman05
	         WHERE cod_manzana = _cod_manzana;

			let _suma_ret = 0;
			let _ret_porc = 0;
			let _suma_fac = 0;
			let _fac_porc = 0;
			let _suma_exc = 0;
			let	_exc_porc = 0;
			let _cod_cober_reas	= null; 
			let	_porc_partic_suma = 0;

			let _no_cambio = null;

		   	SELECT max(no_cambio)
			  INTO _no_cambio
			  FROM emireama
			 WHERE no_poliza      = _no_poliza
			   and no_unidad      = _no_unidad
			   and cod_cober_reas in (select cod_cober_reas from tmp_cober_reas);--= _cod_cober_reas;and cod_cober_reas = _cod_cober_reas;

			FOREACH
				 SELECT cod_contrato,
				        porc_partic_suma
				   INTO v_cod_contrato,
				        _porc_partic_suma
				   FROM emireaco
				  WHERE no_poliza      = _no_poliza
				    AND no_unidad      = _no_unidad
				    AND no_cambio      = _no_cambio
					and cod_cober_reas in (select cod_cober_reas from tmp_cober_reas)--= _cod_cober_reas;AND cod_cober_reas = _cod_cober_reas

			      SELECT tipo_contrato
			        INTO v_tipo_contrato
			        FROM reacomae
			       WHERE cod_contrato = v_cod_contrato;

				  IF _porc_partic_suma IS NULL THEN
				  	  LET _porc_partic_suma = 0;
				  END IF

				  IF _suma_asegurada IS NULL THEN
				  	  LET _suma_asegurada = 0;
				  END IF

			      IF v_tipo_contrato = 1 and _ret_porc = 0 THEN
				  	let _suma_ret = _suma_asegurada * _porc_partic_suma / 100;
				  	let _ret_porc = _porc_partic_suma;
				  end if

			      IF v_tipo_contrato = 3 and _fac_porc = 0 THEN
				  	let _suma_fac = _suma_asegurada * _porc_partic_suma / 100;
				  	let _fac_porc = _porc_partic_suma;
				  end if

			      IF v_tipo_contrato = 7 and _exc_porc = 0 THEN
				  	let _suma_exc = _suma_asegurada * _porc_partic_suma / 100;
				  	let _exc_porc = _porc_partic_suma;
				  end if

		   END FOREACH		

        insert into temp_sis600
		values( _no_poliza, _no_unidad, _no_documento, v_asegurado, _cod_manzana,_referencia, _suc_origen,_n_suc_origen,_suma_asegurada,_tipo_incendio,
	   		    _vig_ini,_vig_fin,_suma_ret, _est_pol, _nombre_ag_acum,_suma_fac,_suma_exc,_ret_porc,_fac_porc,_exc_porc,_prima_suscrita, _coaseguro);	

END FOREACH
	   

--Parámetro para el mensaje de Advertencia (por superar o superado los 500k)
let _suma_ret = 0;
let _flag = 0;
let _mensaje = '';
select sum(tot_retencion)
	into _suma_ret
	from temp_sis600	
   where cod_manzana = a_cod_manzana
   and no_unidad = a_no_unidad;
   
   let _suma_ret = _suma_ret + a_suma_asegurada;
   
if _suma_ret > _max_retencion then  
    let _flag = 1; 	
end if

let _suma_ret = 0;
if _flag = 0 then
	select sum(tot_retencion)
		into _suma_ret
		from temp_sis600	
	   where cod_manzana = a_cod_manzana;
	   
	   let _suma_ret = _suma_ret + a_suma_asegurada;
	if _suma_ret > _max_retencion then 
		let _flag = 2; 
	end if
end if

if _flag = 1 then
	let _mensaje = 'SUMA ASEGURADA EXCEDE LOS B/. 500,000.00 DE RETENCION. FAVOR VERIFIQUE.';
end if
if _flag = 2 then
	let _mensaje = 'MANZANA SELECCIONADA SUPERA EL TOPE DEL CONTRATO DE RETENCION B/. 500,000.00. FAVOR VERIFIQUE.';
end if

return _flag,_mensaje;


	   
	

--trace off;
end procedure